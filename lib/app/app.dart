import 'package:flutter/material.dart';

import 'package:apex/app/theme/app_theme.dart';
import 'package:apex/shared/auth/auth_gate.dart';

class ApexApp extends StatelessWidget {
  const ApexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apex',
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}
