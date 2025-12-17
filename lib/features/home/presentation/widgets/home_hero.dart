import 'package:flutter/material.dart';

import 'package:apex/shared/widgets/feature_section.dart';

class HomeHero extends StatelessWidget {
  const HomeHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeatureSection(
      title: 'Benvenuto ad Apex',
      subtitle: 'Tieni sotto controllo la tua comunità e scopri gli argomenti caldi della giornata.',
      icon: Icons.home,
      color: Color(0xFF12406D),
    );
  }
}
