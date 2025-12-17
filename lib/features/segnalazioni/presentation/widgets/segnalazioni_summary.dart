import 'package:flutter/material.dart';

import 'package:apex/shared/widgets/feature_section.dart';

class SegnalazioniSummary extends StatelessWidget {
  const SegnalazioniSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeatureSection(
      title: 'Segnalazioni aperte',
      subtitle: '6 interventi in corso e 2 pronti per la verifica finale.',
      icon: Icons.report,
      color: Color(0xFFD23F2F),
    );
  }
}
