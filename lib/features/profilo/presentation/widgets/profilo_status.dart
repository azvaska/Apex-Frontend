import 'package:flutter/material.dart';

import 'package:apex/shared/widgets/feature_section.dart';

class ProfiloStatus extends StatelessWidget {
  const ProfiloStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeatureSection(
      title: 'Profilo personale',
      subtitle: 'Aggiorna informazioni, preferenze e disponibilità in tempo reale.',
      icon: Icons.badge,
      color: Color(0xFF7B3F00),
    );
  }
}
