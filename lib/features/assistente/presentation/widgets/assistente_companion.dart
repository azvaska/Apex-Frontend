import 'package:flutter/material.dart';

import 'package:apex/shared/widgets/feature_section.dart';

class AssistenteCompanion extends StatelessWidget {
  const AssistenteCompanion({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeatureSection(
      title: 'Assistente digitale',
      subtitle: 'Suggerimenti contestuali e promemoria automatici per il tuo lavoro sul campo.',
      icon: Icons.smart_toy,
      color: Color(0xFF0F9D58),
    );
  }
}
