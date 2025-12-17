import 'package:flutter/material.dart';

import 'package:apex/features/assistente/presentation/widgets/assistente_companion.dart';
import 'package:apex/shared/widgets/feature_section.dart';

class AssistenteScreen extends StatelessWidget {
  const AssistenteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const AssistenteCompanion(),
        const SizedBox(height: 16),
        FeatureSection(
          title: 'Agenda del giorno',
          subtitle: 'Aggiungi gli incontri e sincronizza gli orari con il tuo team.',
          icon: Icons.calendar_today,
          color: colorScheme.primary,
        ),
        const SizedBox(height: 16),
        FeatureSection(
          title: 'Check di sicurezza',
          subtitle: 'Checklist rapida per verificare le aree prima dell’intervento.',
          icon: Icons.shield,
          color: colorScheme.secondary,
        ),
      ],
    );
  }
}
