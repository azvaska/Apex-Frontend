import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:apex/features/home/data/environmental_repository.dart';
import 'package:apex/features/home/data/home_repository.dart';

class RiskMapSheet extends StatefulWidget {
  final HomeRepository repository;

  const RiskMapSheet({
    super.key,
    required this.repository,
  });

  @override
  State<RiskMapSheet> createState() => _RiskMapSheetState();
}

class _RiskMapSheetState extends State<RiskMapSheet> {
  late Future<_RiskMapData> _dataFuture;
  _AreaRisk? _selected;
  final EnvironmentalRepository _environmentalRepository =
      EnvironmentalRepository();
  final Map<String, EnvironmentalSample> _samplesCache = {};
  bool _isLoadingSample = false;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<_RiskMapData> _loadData() async {
    final results = await Future.wait([
      widget.repository.fetchAreas(),
      widget.repository.fetchActiveAlerts(),
    ]);
    final areas = results[0] as List<AreaSummary>;
    final alerts = results[1] as List<AlertEvent>;
    return _RiskMapData(areas: areas, alerts: alerts);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.zero,
      child: SafeArea(
        top: false,
        child: FutureBuilder<_RiskMapData>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'Errore nel caricamento della mappa.',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() => _dataFuture = _loadData());
                        },
                        child: const Text('Riprova'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = snapshot.data!;
            final risks = _buildRisks(data);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        'Mappa Rischi',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: _MapCanvas(
                          risks: risks,
                          onSelect: (area) {
                            _handleSelect(area);
                          },
                        ),
                      ),
                      if (_selected != null)
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: _AreaDetailCard(
                            area: _selected!,
                            sample: _samplesCache[_selected!.id],
                            isLoadingSample: _isLoadingSample,
                            onClose: () => setState(() => _selected = null),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<_AreaRisk> _buildRisks(_RiskMapData data) {
    final Map<String, AlertEvent> alertsByArea = {};
    for (final alert in data.alerts) {
      final current = alertsByArea[alert.areaId];
      if (current == null || alert.riskIndex > current.riskIndex) {
        alertsByArea[alert.areaId] = alert;
      }
    }
    return data.areas.map((area) {
      final alert = alertsByArea[area.id];
      final riskIndex = alert?.riskIndex ?? 1;
      return _AreaRisk(
        id: area.id,
        name: area.name,
        category: _deriveCategory(alert?.message ?? ''),
        riskIndex: riskIndex,
        message: alert?.message ?? 'Nessuna criticita attiva rilevata.',
        polygons: _parsePolygons(area.geometry),
      );
    }).toList();
  }

  String _deriveCategory(String message) {
    final text = message.toLowerCase();
    if (text.contains('valanga')) {
      return 'Valanghe';
    }
    if (text.contains('frana')) {
      return 'Frane';
    }
    if (text.contains('meteo') || text.contains('temporale')) {
      return 'Meteo';
    }
    return 'Monitoraggio';
  }

  Future<void> _handleSelect(_AreaRisk area) async {
    setState(() {
      _selected = area;
      _isLoadingSample = !_samplesCache.containsKey(area.id);
    });
    if (_samplesCache.containsKey(area.id)) {
      return;
    }
    try {
      final sample =
          await _environmentalRepository.fetchLatestSample(area.id);
      if (!mounted) {
        return;
      }
      setState(() {
        _samplesCache[area.id] = sample;
        _isLoadingSample = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingSample = false;
      });
    }
  }
}

class _MapCanvas extends StatelessWidget {
  final List<_AreaRisk> risks;
  final ValueChanged<_AreaRisk> onSelect;

  const _MapCanvas({
    required this.risks,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (risks.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: const Color(0xFFEFF7F4),
        ),
        child: const Center(
          child: Text('Nessuna area disponibile.'),
        ),
      );
    }

    final polygons = <Polygon>[];
    final markers = <Marker>[];
    final allPoints = <LatLng>[];
    for (final area in risks) {
      final style = _riskStyle(area.riskIndex);
      if (area.polygons.isNotEmpty) {
        for (final ring in area.polygons) {
          polygons.add(
            Polygon(
              points: ring,
              color: style.fill,
              borderStrokeWidth: 2,
              borderColor: style.stroke,
              isFilled: true,
            ),
          );
          allPoints.addAll(ring);
        }
        final center = _centroid(area.polygons.first);
        markers.add(
          Marker(
            point: center,
            width: 36,
            height: 36,
            child: GestureDetector(
              onTap: () => onSelect(area),
              child: _MapMarkerDot(color: style.stroke),
            ),
          ),
        );
      }
    }

    final bounds = allPoints.isEmpty ? null : LatLngBounds.fromPoints(allPoints);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFFEFF7F4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: bounds?.center ?? const LatLng(46.4, 11.9),
                initialZoom: bounds == null ? 9 : 10,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
                ),
                initialCameraFit: bounds == null
                    ? null
                    : CameraFit.bounds(
                        bounds: bounds,
                        padding: const EdgeInsets.all(24),
                      ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.apex.apex',
                ),
                if (polygons.isNotEmpty)
                  PolygonLayer(polygons: polygons),
                if (markers.isNotEmpty)
                  MarkerLayer(markers: markers),
              ],
            ),
            Positioned(
              top: 16,
              right: 16,
              child: _LegendCard(),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: theme.colorScheme.outline),
              const SizedBox(width: 6),
              Text(
                'Legenda',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _LegendRow(label: 'Alto', color: const Color(0xFFE03A3E)),
          _LegendRow(label: 'Medio', color: const Color(0xFFF97316)),
          _LegendRow(label: 'Basso', color: const Color(0xFF16A34A)),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendRow({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _MapMarkerDot extends StatelessWidget {
  final Color color;

  const _MapMarkerDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
    );
  }
}

class _AreaDetailCard extends StatelessWidget {
  final _AreaRisk area;
  final VoidCallback onClose;
  final EnvironmentalSample? sample;
  final bool isLoadingSample;

  const _AreaDetailCard({
    required this.area,
    required this.onClose,
    required this.sample,
    required this.isLoadingSample,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final riskLabel = area.riskIndex >= 4
        ? 'Alto'
        : area.riskIndex >= 2
            ? 'Medio'
            : 'Basso';
    final riskColor = area.riskIndex >= 4
        ? const Color(0xFFE03A3E)
        : area.riskIndex >= 2
            ? const Color(0xFFF97316)
            : const Color(0xFF16A34A);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      area.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      area.category,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: riskColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: riskColor.withOpacity(0.35)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: riskColor),
                const SizedBox(width: 8),
                Text(
                  'Livello di Rischio',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const Spacer(),
                Text(
                  riskLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: riskColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Condizioni Meteo',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (isLoadingSample)
            const LinearProgressIndicator(minHeight: 2)
          else if (sample == null)
            Text(
              'Dati meteo non disponibili.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 64) / 2,
                  child: _MetricTile(
                    label: 'Temperatura',
                    value: '${sample!.airTemperatureC.toStringAsFixed(1)}°C',
                    color: const Color(0xFFE3F0FF),
                    icon: Icons.device_thermostat_outlined,
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 64) / 2,
                  child: _MetricTile(
                    label: 'Vento',
                    value: '${_msToKmh(sample!.windSpeedMs)} km/h',
                    color: const Color(0xFFE7FAFF),
                    icon: Icons.air,
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 64) / 2,
                  child: _MetricTile(
                    label: 'Precipitazioni',
                    value:
                        '${sample!.precipitationMm.toStringAsFixed(1)} mm',
                    color: const Color(0xFFEFF2FF),
                    icon: Icons.grain,
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 64) / 2,
                  child: _MetricTile(
                    label: 'Umidita',
                    value: '${sample!.relativeHumidity.toStringAsFixed(0)}%',
                    color: const Color(0xFFF6ECFF),
                    icon: Icons.water_drop_outlined,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(height: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskMapData {
  final List<AreaSummary> areas;
  final List<AlertEvent> alerts;

  _RiskMapData({
    required this.areas,
    required this.alerts,
  });
}

class _AreaRisk {
  final String id;
  final String name;
  final String category;
  final int riskIndex;
  final String message;
  final List<List<LatLng>> polygons;

  _AreaRisk({
    required this.id,
    required this.name,
    required this.category,
    required this.riskIndex,
    required this.message,
    required this.polygons,
  });
}

class _RiskPalette {
  final Color stroke;
  final Color fill;

  const _RiskPalette({required this.stroke, required this.fill});
}

_RiskPalette _riskStyle(int riskIndex) {
  final stroke = riskIndex >= 4
      ? const Color(0xFFE03A3E)
      : riskIndex >= 2
          ? const Color(0xFFF97316)
          : const Color(0xFF16A34A);
  final fill = stroke.withOpacity(0.25);
  return _RiskPalette(stroke: stroke, fill: fill);
}

List<List<LatLng>> _parsePolygons(Map<String, dynamic> geometry) {
  final type = geometry['type'] as String? ?? '';
  final coords = geometry['coordinates'];
  if (coords == null) {
    return [];
  }
  if (type == 'Polygon' && coords is List) {
    return coords
        .map<List<LatLng>>((ring) => _parseRing(ring))
        .where((ring) => ring.isNotEmpty)
        .toList();
  }
  if (type == 'MultiPolygon' && coords is List) {
    final List<List<LatLng>> rings = [];
    for (final polygon in coords) {
      if (polygon is List) {
        for (final ring in polygon) {
          final parsed = _parseRing(ring);
          if (parsed.isNotEmpty) {
            rings.add(parsed);
          }
        }
      }
    }
    return rings;
  }
  return [];
}

List<LatLng> _parseRing(dynamic ring) {
  if (ring is! List) {
    return [];
  }
  return ring
      .whereType<List>()
      .map((point) {
        final lng = (point.isNotEmpty ? point[0] : 0) as num?;
        final lat = (point.length > 1 ? point[1] : 0) as num?;
        if (lat == null || lng == null) {
          return null;
        }
        return LatLng(lat.toDouble(), lng.toDouble());
      })
      .whereType<LatLng>()
      .toList();
}

LatLng _centroid(List<LatLng> points) {
  if (points.isEmpty) {
    return const LatLng(46.4, 11.9);
  }
  double lat = 0;
  double lng = 0;
  for (final point in points) {
    lat += point.latitude;
    lng += point.longitude;
  }
  return LatLng(lat / points.length, lng / points.length);
}

double _msToKmh(double speedMs) {
  return (speedMs * 3.6).roundToDouble();
}
