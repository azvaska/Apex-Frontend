import 'package:flutter/material.dart';

import 'package:apex/features/guida/models/guide_models.dart';

class GuidaScreen extends StatelessWidget {
  final ValueChanged<EmergencyContact>? onCallContact;
  final ValueChanged<QuickGuide>? onOpenGuide;
  final VoidCallback? onRefreshOffline;
  final String? lastUpdatedLabel;

  const GuidaScreen({
    super.key,
    this.onCallContact,
    this.onOpenGuide,
    this.onRefreshOffline,
    this.lastUpdatedLabel,
  });

  static const List<EmergencyContact> _contacts = [
    EmergencyContact(
      name: 'Soccorso Alpino',
      subtitle: 'Emergenza',
      number: '118',
      kind: ContactKind.emergency,
      accent: Color(0xFFDF0B16),
    ),
    EmergencyContact(
      name: 'Carabinieri',
      subtitle: 'Emergenza',
      number: '112',
      kind: ContactKind.emergency,
      accent: Color(0xFFDF0B16),
    ),
    EmergencyContact(
      name: 'Vigili del Fuoco',
      subtitle: 'Emergenza',
      number: '115',
      kind: ContactKind.emergency,
      accent: Color(0xFFDF0B16),
    ),
    EmergencyContact(
      name: 'Protezione Civile Veneto',
      subtitle: 'Info',
      number: '800 990 009',
      kind: ContactKind.info,
      accent: Color(0xFF1368FF),
    ),
    EmergencyContact(
      name: 'ARPAV Meteo',
      subtitle: 'Info',
      number: '049 9998111',
      kind: ContactKind.info,
      accent: Color(0xFF1368FF),
    ),
  ];

  static const List<QuickGuide> _guides = [
    QuickGuide(
      title: 'Primo Soccorso',
      description: 'Kit minimo, controllo vittima, allertare i soccorsi',
      icon: Icons.medical_services_outlined,
      tint: Color(0xFFFF6B6B),
    ),
    QuickGuide(
      title: 'Bivacco di emergenza',
      description: 'Riparo, segnalazione visiva, gestione risorse',
      icon: Icons.park_outlined,
      tint: Color(0xFF4CAF50),
    ),
    QuickGuide(
      title: 'Meteo improvviso',
      description: 'Segnali pre-frontali, cosa fare con vento/neve',
      icon: Icons.cloud_sync_outlined,
      tint: Color(0xFF2196F3),
    ),
    QuickGuide(
      title: 'Orientamento offline',
      description: 'Azimut, punti di riferimento, uso bussola e mappa',
      icon: Icons.explore_outlined,
      tint: Color(0xFF9C27B0),
    ),
  ];

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
              'Guida Offline',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 20),
            _SectionHeader(
              icon: Icons.local_phone,
              iconColor: Colors.red.shade600,
              title: 'Numeri di Emergenza',
            ),
            const SizedBox(height: 12),
            Column(
              children: _contacts
                  .map(
                    (contact) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ContactCard(
                        contact: contact,
                        onTap: () => onCallContact?.call(contact),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            _SectionHeader(
              icon: Icons.menu_book_outlined,
              iconColor: colorScheme.primary,
              title: 'Procedure di Emergenza',
            ),
            const SizedBox(height: 12),
            Column(
              children: _guides
                  .map(
                    (guide) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _GuideCard(
                        guide: guide,
                        onTap: () => onOpenGuide?.call(guide),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  final String message;
  final String updatedLabel;
  final VoidCallback? onRefresh;

  const _OfflineBanner({
    required this.message,
    required this.updatedLabel,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F7EB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB3E5C1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 4),
            decoration: const BoxDecoration(
              color: Color(0xFF2EBC7A),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.green.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  updatedLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
          ),
          if (onRefresh != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              color: Colors.green.shade800,
              onPressed: onRefresh,
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;

  const _SectionHeader({
    required this.icon,
    required this.iconColor,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  final EmergencyContact contact;
  final VoidCallback? onTap;

  const _ContactCard({
    required this.contact,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEmergency = contact.kind == ContactKind.emergency;
    final accent = contact.accent;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        title: Text(
          contact.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          contact.subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade700,
          ),
        ),
        trailing: _CallButton(
          number: contact.number,
          accent: accent,
          onTap: onTap,
          isEmergency: isEmergency,
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final String number;
  final Color accent;
  final bool isEmergency;
  final VoidCallback? onTap;

  const _CallButton({
    required this.number,
    required this.accent,
    required this.isEmergency,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(isEmergency ? 26 : 18),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.28),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.call_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              number,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  final QuickGuide guide;
  final VoidCallback? onTap;

  const _GuideCard({
    required this.guide,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: guide.tint.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(guide.icon, color: guide.tint),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guide.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      guide.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade500),
            ],
          ),
        ),
      ),
    );
  }
}
