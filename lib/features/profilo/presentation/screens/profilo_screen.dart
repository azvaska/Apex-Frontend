import 'package:flutter/material.dart';

import 'package:apex/features/profilo/models/profile_models.dart';
import 'package:apex/features/profilo/presentation/widgets/profile_action_tile.dart';
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
  final VoidCallback? onAddArea;
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
  late ProfileUser _user;
  late List<MonitoredArea> _areas;

  @override
  void initState() {
    super.initState();
    _user = widget.user ?? const ProfileUser(
      firstName: 'Mario',
      lastName: 'Rossi',
      email: 'mario.rossi@email.com',
    );
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
  }

  Future<void> _openEditProfileSheet() async {
    final updatedUser = await showModalBottomSheet<ProfileUser>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ProfileEditSheet(user: _user),
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
        onAddArea: widget.onAddArea,
        onRemoveArea: (area) {
          widget.onRemoveArea?.call(area);
          setState(() {
            _areas = List.of(_areas)..remove(area);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
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
      ),
    );
  }
}
