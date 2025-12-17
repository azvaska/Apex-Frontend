import 'package:flutter/material.dart';

import 'package:apex/shared/widgets/feature_section.dart';

class GuidaNavigator extends StatelessWidget {
  const GuidaNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeatureSection(
      title: 'Guida rapida',
      subtitle: 'Mappe, procedure e contatti essenziali a portata di mano.',
      icon: Icons.map,
      color: Color(0xFF006D77),
    );
  }
}
