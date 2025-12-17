import 'package:flutter/material.dart';

import 'package:apex/features/segnalazioni/presentation/widgets/segnalazioni_summary.dart';
import 'package:apex/shared/widgets/feature_section.dart';

class SegnalazioniScreen extends StatelessWidget {
  const SegnalazioniScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SegnalazioniSummary(),
        const SizedBox(height: 16),
        FeatureSection(
          title: 'Raccogli evidenze',
          subtitle: 'Fotografa e annota il contesto prima di inoltrare la segnalazione.',
          icon: Icons.camera_alt,
          color: colorScheme.secondary,
          action: TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.camera),
            label: const Text('Aggiungi media'),
          ),
        ),
        const SizedBox(height: 16),
        FeatureSection(
          title: 'Filtri dinamici',
          subtitle: 'Ordina per priorità, stato e prossima scadenza.',
          icon: Icons.filter_list,
          color: colorScheme.tertiaryContainer,
        ),
      ],
    );
  }
}
