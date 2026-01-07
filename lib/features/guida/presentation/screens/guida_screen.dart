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
      steps: [
        'Metti in sicurezza la zona e la persona.',
        'Controlla coscienza e respirazione.',
        'Chiama i soccorsi e indica la posizione.',
        'Proteggi dal freddo con coperta o indumenti.',
      ],
      icon: Icons.medical_services_outlined,
      tint: Color(0xFFFF6B6B),
    ),
    QuickGuide(
      title: 'Bivacco di emergenza',
      description: 'Riparo, segnalazione visiva, gestione risorse',
      steps: [
        'Scegli un punto riparato dal vento.',
        'Usa telo o zaino per isolarti dal terreno.',
        'Mantieni energia e calore con movimenti leggeri.',
        'Segnala la posizione con luce o fischietto.',
      ],
      icon: Icons.park_outlined,
      tint: Color(0xFF4CAF50),
    ),
    QuickGuide(
      title: 'Meteo improvviso',
      description: 'Segnali pre-frontali, cosa fare con vento/neve',
      steps: [
        'Cerca riparo e riduci l\'esposizione in cresta.',
        'Riorganizza il gruppo e resta unito.',
        'Usa strati impermeabili e protezione occhi.',
        'Valuta un rientro rapido verso il punto sicuro.',
      ],
      icon: Icons.cloud_sync_outlined,
      tint: Color(0xFF2196F3),
    ),
    QuickGuide(
      title: 'Orientamento offline',
      description: 'Azimut, punti di riferimento, uso bussola e mappa',
      steps: [
        'Individua un riferimento stabile nel territorio.',
        'Calcola l\'azimut con bussola o app offline.',
        'Segui tappe brevi e controlla la posizione spesso.',
        'Se perdi il sentiero, torna all\'ultimo punto noto.',
      ],
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
                        onTap: () => _handleGuideTap(context, guide),
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

void _handleGuideTap(BuildContext context, QuickGuide guide) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _GuideDetailSheet(guide: guide),
  );
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

class _GuideDetailSheet extends StatelessWidget {
  final QuickGuide guide;

  const _GuideDetailSheet({required this.guide});

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
                Expanded(
                  child: Text(
                    guide.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              guide.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),
            ...guide.steps.map(
              (step) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: guide.tint,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        step,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
