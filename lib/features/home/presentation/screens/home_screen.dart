import 'package:flutter/material.dart';

import 'package:apex/features/home/data/home_repository.dart';
import 'package:apex/features/home/presentation/widgets/risk_map_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeRepository _repository = HomeRepository();
  late Future<List<AlertEvent>> _alertsFuture;

  @override
  void initState() {
    super.initState();
    _alertsFuture = _repository.fetchActiveAlerts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: FutureBuilder<List<AlertEvent>>(
        future: _alertsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Errore nel caricamento delle allerte.',
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
                        setState(() {
                          _alertsFuture = _repository.fetchActiveAlerts();
                        });
                      },
                      child: const Text('Riprova'),
                    ),
                  ],
                ),
              ),
            );
          }

          final alerts = snapshot.data ?? [];
          final updatedLabel = alerts.isEmpty
              ? 'Nessuna allerta'
              : 'Aggiornato ${_timeAgo(alerts.first.createdAt)}';

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              Text(
                'ApeX',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Color(0xFFE03A3E)),
                  const SizedBox(width: 8),
                  Text(
                    'Allerte Attive',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    updatedLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (alerts.isEmpty)
                _EmptyAlertCard()
              else
                ...alerts.map(
                  (alert) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AlertCard(alert: alert),
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Mappa Rischi',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _MapPreviewCard(
                onTap: () => _openMap(context),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}

Future<void> _openMap(BuildContext context) async {
  final repository = HomeRepository();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => SizedBox(
      height: MediaQuery.of(context).size.height,
      child: RiskMapSheet(repository: repository),
    ),
  );
}

class _AlertCard extends StatelessWidget {
  final AlertEvent alert;

  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = _alertStyle(alert);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(18),
        border: Border(
          left: BorderSide(width: 4, color: style.accent),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: style.accent.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(style.icon, color: style.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  style.label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alert.areaName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  alert.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: style.accent.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              style.levelLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: style.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAlertCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Nessuna criticita attiva nelle aree monitorate.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPreviewCard extends StatelessWidget {
  final VoidCallback onTap;

  const _MapPreviewCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFFF4FAD3), Color(0xFFF9D5E2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    _MapDot(color: const Color(0xFFF0726E)),
                    const SizedBox(width: 16),
                    _MapDot(color: const Color(0xFFF3B562)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: theme.colorScheme.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Tocca per aprire la mappa',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Visualizza zone a rischio',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: _MapDot(color: const Color(0xFF22C55E)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapDot extends StatelessWidget {
  final Color color;

  const _MapDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _AlertStyle {
  final String label;
  final String levelLabel;
  final IconData icon;
  final Color accent;
  final Color background;

  const _AlertStyle({
    required this.label,
    required this.levelLabel,
    required this.icon,
    required this.accent,
    required this.background,
  });
}

_AlertStyle _alertStyle(AlertEvent alert) {
  final message = alert.message.toLowerCase();
  final isAvalanche = message.contains('valanga');
  final isLandslide = message.contains('frana');
  final isStorm = message.contains('meteo') || message.contains('temporale');
  final label = isAvalanche
      ? 'Valanghe'
      : isLandslide
          ? 'Frane'
          : isStorm
              ? 'Meteo'
              : 'Allerta';
  final icon = isAvalanche
      ? Icons.terrain_rounded
      : isLandslide
          ? Icons.warning_amber_rounded
          : isStorm
              ? Icons.thunderstorm_rounded
              : Icons.report_gmailerrorred_rounded;
  final level = alert.riskIndex >= 4
      ? 'ALTO'
      : alert.riskIndex >= 2
          ? 'MEDIO'
          : 'BASSO';
  final accent = alert.riskIndex >= 4
      ? const Color(0xFFE03A3E)
      : alert.riskIndex >= 2
          ? const Color(0xFFF97316)
          : const Color(0xFF16A34A);
  final background = alert.riskIndex >= 4
      ? const Color(0xFFFFF1F1)
      : alert.riskIndex >= 2
          ? const Color(0xFFFFF4E8)
          : const Color(0xFFF2FDF5);
  return _AlertStyle(
    label: label,
    levelLabel: level,
    icon: icon,
    accent: accent,
    background: background,
  );
}

String _timeAgo(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 5) {
    return 'ora';
  }
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes} min fa';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours} ore fa';
  }
  return '${diff.inDays} giorni fa';
}
