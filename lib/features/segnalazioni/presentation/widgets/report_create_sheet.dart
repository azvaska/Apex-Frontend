import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import 'package:apex/features/segnalazioni/data/report_repository.dart';
import 'package:apex/features/segnalazioni/models/report_models.dart';

class ReportCreateSheet extends StatefulWidget {
  final ReportRepository repository;
  final Future<void> Function()? onCreated;

  const ReportCreateSheet({
    super.key,
    required this.repository,
    this.onCreated,
  });

  @override
  State<ReportCreateSheet> createState() => _ReportCreateSheetState();
}

class _ReportCreateSheetState extends State<ReportCreateSheet> {
  static const int _maxImageBytes = 90 * 1024;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedType = 'Frana';
  late Future<List<AreaOfInterest>> _areasFuture;
  AreaOfInterest? _selectedArea;
  bool _isSubmitting = false;
  List<AreaOfInterest> _areas = const [];
  String? _formError;
  Uint8List? _imageBytes;
  String? _imageDataUrl;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _areasFuture = widget.repository.fetchAreas();
    _areasFuture.then((areas) {
      if (mounted) {
        setState(() {
          _areas = areas;
          _selectedArea ??= areas.isNotEmpty ? areas.first : null;
        });
      }
    }).catchError((_) {
      if (mounted) {
        setState(() {
          _areas = const [];
        });
      }
    });
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    setState(() => _formError = null);
    if (title.isEmpty || description.isEmpty) {
      setState(() => _formError = 'Compila titolo e descrizione.');
      return;
    }
    if (_selectedArea == null) {
      setState(() => _formError = 'Seleziona una posizione.');
      return;
    }
    final normalizedTitle = title.toLowerCase().contains(_selectedType.toLowerCase())
        ? title
        : '$_selectedType: $title';
    setState(() => _isSubmitting = true);
    try {
      await widget.repository.createReport(
        title: normalizedTitle,
        text: description,
        areaId: _selectedArea!.id,
        imageDataUrl: _imageDataUrl,
      );
      if (widget.onCreated != null) {
        await widget.onCreated!();
      }
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      setState(() => _formError = 'Errore: $error');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _selectArea() async {
    final areas = await _areasFuture;
    if (!mounted || areas.isEmpty) {
      return;
    }
    final selection = await showModalBottomSheet<AreaOfInterest>(
      context: context,
      builder: (context) => _AreaPickerSheet(
        areas: areas,
        selected: _selectedArea,
      ),
    );
    if (selection != null) {
      setState(() => _selectedArea = selection);
    }
  }

  Future<void> _showImageSourcePicker() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: const Text('Scatta una foto'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Scegli dalla galleria'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (picked == null) {
        return;
      }
      final compressed = await _compressImage(picked);
      if (compressed == null || compressed.isEmpty) {
        if (!mounted) {
          return;
        }
        setState(() => _formError = 'Impossibile comprimere la foto.');
        return;
      }
      if (compressed.length > _maxImageBytes) {
        if (!mounted) {
          return;
        }
        setState(() {
          _formError =
              'Foto troppo grande. Scegli un\'immagine piu piccola.';
        });
        return;
      }
      final mime = picked.mimeType ?? _inferMime(picked.path);
      final dataUrl = 'data:$mime;base64,${base64Encode(compressed)}';
      if (!mounted) {
        return;
      }
      setState(() {
        _imageBytes = compressed;
        _imageDataUrl = dataUrl;
        _formError = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _formError = 'Errore: $error');
    }
  }

  Future<Uint8List?> _compressImage(XFile picked) async {
    const minWidth = 1200;
    const minHeight = 1200;
    final targetPath = picked.path;
    for (final quality in [80, 70, 60, 50, 40]) {
      final result = await FlutterImageCompress.compressWithFile(
        targetPath,
        quality: quality,
        minWidth: minWidth,
        minHeight: minHeight,
        format: CompressFormat.jpeg,
      );
      if (result != null && result.length <= _maxImageBytes) {
        return result;
      }
    }
    return FlutterImageCompress.compressWithFile(
      targetPath,
      quality: 30,
      minWidth: minWidth ~/ 2,
      minHeight: minHeight ~/ 2,
      format: CompressFormat.jpeg,
    );
  }

  String _inferMime(String path) {
    final parts = path.split('.');
    if (parts.length < 2) {
      return 'image/jpeg';
    }
    final ext = parts.last.toLowerCase();
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final types = const [
      _ReportTypeOption('Frana', Icons.warning_amber_rounded),
      _ReportTypeOption('Valanga', Icons.ac_unit_rounded),
      _ReportTypeOption('Meteo Avverso', Icons.thunderstorm_rounded),
      _ReportTypeOption('Sentiero Bloccato', Icons.signpost_rounded),
    ];

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Nuova Segnalazione',
                    style: theme.textTheme.titleLarge?.copyWith(
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
              const SizedBox(height: 8),
              Text(
                'Tipo di Segnalazione',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: types.map((type) {
                  final isSelected = _selectedType == type.label;
                  return _TypeCard(
                    option: type,
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedType = type.label),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text(
                'Titolo',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Es. Frana sulla strada provinciale',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Descrizione',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                minLines: 4,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Descrivi la situazione in dettaglio...',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Aggiungi Foto',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _imageBytes == null ? _showImageSourcePicker : null,
                child: _DashedBorder(
                  radius: 16,
                  color: theme.colorScheme.outlineVariant,
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: _imageBytes == null
                          ? Column(
                              children: [
                                Icon(Icons.camera_alt_outlined,
                                    color: theme.colorScheme.outline, size: 36),
                                const SizedBox(height: 8),
                                Text(
                                  'Scatta o carica una foto',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.outline,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                              : Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.memory(
                                        _imageBytes!,
                                        height: 160,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _imageBytes = null;
                                            _imageDataUrl = null;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(Icons.close,
                                              size: 16, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                    ),
                  ),
                ),
              ),
              if (_imageBytes != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showImageSourcePicker,
                    child: const Text('Cambia foto'),
                  ),
                ),
              const SizedBox(height: 18),
              Text(
                'Posizione',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<AreaOfInterest>>(
                future: _areasFuture,
                builder: (context, snapshot) {
                  return InkWell(
                    onTap: snapshot.hasData ? _selectArea : null,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.place_outlined,
                              color: theme.colorScheme.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedArea?.name ??
                                      (snapshot.hasError
                                          ? 'Errore nel caricare le posizioni'
                                          : 'Seleziona una posizione'),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  snapshot.connectionState ==
                                          ConnectionState.waiting
                                      ? 'Caricamento posizioni...'
                                      : _areas.isEmpty
                                          ? 'Nessuna posizione disponibile'
                                      : 'GPS attivo',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.green.shade500,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              if (_formError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _formError!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _isSubmitting || _areas.isEmpty ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                  label: const Text('Invia Segnalazione'),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final _ReportTypeOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor =
        isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width - 44) / 2,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              option.icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              option.label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportTypeOption {
  final String label;
  final IconData icon;

  const _ReportTypeOption(this.label, this.icon);
}

class _DashedBorder extends StatelessWidget {
  final Widget child;
  final double radius;
  final Color color;

  const _DashedBorder({
    required this.child,
    required this.radius,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRectPainter(radius: radius, color: color),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child,
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final double radius;
  final Color color;

  _DashedRectPainter({required this.radius, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 6.0;
    const dashGap = 4.0;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics().first;
    double distance = 0;
    while (distance < metrics.length) {
      final next = distance + dashWidth;
      canvas.drawPath(
        metrics.extractPath(distance, next),
        paint,
      );
      distance = next + dashGap;
    }
  }

  @override
  bool shouldRepaint(_DashedRectPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}

class _AreaPickerSheet extends StatelessWidget {
  final List<AreaOfInterest> areas;
  final AreaOfInterest? selected;

  const _AreaPickerSheet({
    required this.areas,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Seleziona posizione',
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
            const SizedBox(height: 8),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: areas.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final area = areas[index];
                  final isSelected = selected?.id == area.id;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: Icon(Icons.place_outlined,
                        color: theme.colorScheme.primary),
                    title: Text(area.name),
                    trailing: isSelected
                        ? Icon(Icons.check_circle,
                            color: theme.colorScheme.primary)
                        : null,
                    onTap: () => Navigator.of(context).pop(area),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
