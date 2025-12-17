import 'package:flutter/material.dart';

import 'package:apex/features/home/presentation/widgets/home_hero.dart';
import 'package:apex/shared/widgets/feature_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const HomeHero(),
        const SizedBox(height: 16),
        FeatureSection(
          title: 'Segnalazioni in evidenza',
          subtitle: 'Controlla gli aggiornamenti recenti e gli interventi programmati.',
          icon: Icons.signal_cellular_alt,
          color: colorScheme.primary,
        ),
        const SizedBox(height: 16),
        FeatureSection(
          title: 'Appunti veloci',
          subtitle: 'Salva note rapide per i tuoi prossimi passaggi sul territorio.',
          icon: Icons.note_alt,
          color: colorScheme.secondary,
          action: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Nuovo appunto'),
          ),
        ),
      ],
    );
  }
}
