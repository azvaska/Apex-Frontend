import 'package:flutter/material.dart';

import 'package:apex/features/profilo/data/profile_repository.dart';
import 'package:apex/features/profilo/models/profile_models.dart';
import 'package:apex/features/profilo/presentation/widgets/profile_action_tile.dart';
import 'package:apex/features/profilo/presentation/widgets/profile_add_area_sheet.dart';
import 'package:apex/features/profilo/presentation/widgets/profile_areas_sheet.dart';
import 'package:apex/features/profilo/presentation/widgets/profile_edit_sheet.dart';
import 'package:apex/features/profilo/presentation/widgets/profile_header_card.dart';

class ProfiloScreen extends StatefulWidget {
  final ProfileUser? user;
  final List<MonitoredArea>? monitoredAreas;
  final ValueChanged<ProfileUser>? onProfileUpdated;
  final VoidCallback? onOpenNotifications;
  final VoidCallback? onOpenInfoSupport;
  final VoidCallback? onLogout;
  final ValueChanged<AddAreaSelection>? onAddArea;
  final ValueChanged<MonitoredArea>? onRemoveArea;

  const ProfiloScreen({
    super.key,
    this.user,
    this.monitoredAreas,
    this.onProfileUpdated,
    this.onOpenNotifications,
    this.onOpenInfoSupport,
    this.onLogout,
    this.onAddArea,
    this.onRemoveArea,
  });

  @override
  State<ProfiloScreen> createState() => _ProfiloScreenState();
}

class _ProfiloScreenState extends State<ProfiloScreen> {
  final ProfileRepository _repository = ProfileRepository();
  late ProfileUser _user;
  late Future<ProfileUser> _userFuture;
  late List<MonitoredArea> _areas;
  late final List<AreaOption> _availableAreas;

  @override
  void initState() {
    super.initState();
    _user = widget.user ??
        const ProfileUser(
          id: 'local',
          firstName: '',
          lastName: '',
          email: '',
        );
    _userFuture = _repository.fetchCurrentUser();
    _areas = widget.monitoredAreas ?? const [
      MonitoredArea(
        name: "Cortina d'Ampezzo",
        category: 'Valanghe',
        riskLevel: RiskLevel.high,
      ),
      MonitoredArea(
        name: 'Rifugio Auronzo',
        category: 'Frane',
        riskLevel: RiskLevel.medium,
      ),
      MonitoredArea(
        name: 'Val di Fassa',
        category: 'Meteo',
        riskLevel: RiskLevel.low,
      ),
    ];
    _availableAreas = const [
      AreaOption(name: "Cortina d'Ampezzo", detail: 'Comune · Belluno'),
      AreaOption(name: 'Val di Fassa', detail: 'Valle · Trento'),
      AreaOption(name: 'Rifugio Lagazuoi', detail: 'Rifugio · Belluno'),
      AreaOption(name: 'Rifugio Auronzo', detail: 'Rifugio · Belluno'),
      AreaOption(name: 'Canazei', detail: 'Comune · Trento'),
      AreaOption(name: 'San Martino di Castrozza', detail: 'Comune · Trento'),
    ];
  }

  Future<void> _openEditProfileSheet() async {
    final updatedUser = await showModalBottomSheet<ProfileUser>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ProfileEditSheet(
        user: _user,
        repository: _repository,
      ),
    );

    if (updatedUser != null) {
      setState(() => _user = updatedUser);
      widget.onProfileUpdated?.call(updatedUser);
    }
  }

  Future<void> _openAreasSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ProfileAreasSheet(
        areas: _areas,
        onAddArea: () => _openAddAreaSheet(),
        onRemoveArea: (area) {
          widget.onRemoveArea?.call(area);
          setState(() {
            _areas = List.of(_areas)..remove(area);
          });
        },
      ),
    );
  }

  Future<void> _openAddAreaSheet() async {
    final selection = await showModalBottomSheet<AddAreaSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ProfileAddAreaSheet(
        availableAreas: _availableAreas,
      ),
    );

    if (selection != null) {
      widget.onAddArea?.call(selection);
      setState(() {
        _areas = List.of(_areas)
          ..add(
            MonitoredArea(
              name: selection.area.name,
              category: selection.risks.map((r) => r.label).join(' · '),
              riskLevel: RiskLevel.medium,
            ),
          );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: FutureBuilder<ProfileUser>(
        future: _userFuture,
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
                      'Errore nel caricamento del profilo.',
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
                          _userFuture = _repository.fetchCurrentUser();
                        });
                      },
                      child: const Text('Riprova'),
                    ),
                  ],
                ),
              ),
            );
          }
          _user = snapshot.data ?? _user;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profilo',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                ProfileHeaderCard(
                  user: _user,
                  onEditProfile: _openEditProfileSheet,
                ),
                const SizedBox(height: 20),
                Text(
                  'Azioni rapide',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                ProfileActionTile(
                  icon: Icons.location_on_rounded,
                  accentColor: colorScheme.primary,
                  title: 'Aree Monitorate',
                  subtitle: 'Gestisci le tue zone di interesse',
                  onTap: _openAreasSheet,
                ),
                const SizedBox(height: 12),
                ProfileActionTile(
                  icon: Icons.notifications_active_outlined,
                  accentColor: const Color(0xFFF29D38),
                  title: 'Notifiche',
                  subtitle: 'Preferenze e livelli di allerta',
                  onTap: widget.onOpenNotifications,
                ),
                const SizedBox(height: 12),
                ProfileActionTile(
                  icon: Icons.info_outline,
                  accentColor: const Color(0xFF8A6CFF),
                  title: 'Info e Supporto',
                  subtitle: 'Aiuto e informazioni',
                  onTap: widget.onOpenInfoSupport,
                ),
                const SizedBox(height: 18),
                ProfileActionTile(
                  icon: Icons.logout_rounded,
                  accentColor: Colors.red.shade600,
                  title: 'Esci dall\'account',
                  subtitle: 'Termina la sessione corrente',
                  onTap: widget.onLogout,
                  isDestructive: true,
                  trailing: const SizedBox.shrink(),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'ApeX v1.0.0',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
