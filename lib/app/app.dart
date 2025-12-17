import 'package:flutter/material.dart';

import 'package:apex/app/shell/app_shell.dart';
import 'package:apex/app/theme/app_theme.dart';

class ApexApp extends StatelessWidget {
  const ApexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apex',
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      home: const AppShell(),
    );
  }
}
