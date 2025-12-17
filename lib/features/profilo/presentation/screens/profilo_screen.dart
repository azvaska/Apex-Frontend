import 'package:flutter/material.dart';

import 'package:apex/features/profilo/presentation/widgets/profilo_status.dart';
import 'package:apex/shared/widgets/feature_section.dart';

class ProfiloScreen extends StatelessWidget {
  const ProfiloScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const ProfiloStatus(),
        const SizedBox(height: 16),
        FeatureSection(
          title: 'Obiettivi personali',
          subtitle: 'Monitora i tuoi progressi e premi legati alle attività svolte.',
          icon: Icons.star,
          color: colorScheme.primary,
        ),
        const SizedBox(height: 16),
        FeatureSection(
          title: 'Impostazioni',
          subtitle: 'Personalizza notifiche, privacy e integrazioni con altri servizi.',
          icon: Icons.settings,
          color: colorScheme.tertiary,
        ),
      ],
    );
  }
}
