import 'package:flutter/material.dart';

import 'package:apex/features/guida/presentation/widgets/guida_nav.dart';
import 'package:apex/shared/widgets/feature_section.dart';

class GuidaScreen extends StatelessWidget {
  const GuidaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const GuidaNavigator(),
        const SizedBox(height: 16),
        FeatureSection(
          title: 'Percorsi consigliati',
          subtitle: 'Trova il percorso più efficiente in base alla tua posizione attuale.',
          icon: Icons.directions,
          color: colorScheme.secondary,
        ),
        const SizedBox(height: 16),
        FeatureSection(
          title: 'Documentazione in evidenza',
          subtitle: 'Accesso rapido alle procedure e ai manuali digitali.',
          icon: Icons.menu_book,
          color: colorScheme.primary,
        ),
      ],
    );
  }
}
