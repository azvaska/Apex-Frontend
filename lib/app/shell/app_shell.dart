import 'package:flutter/material.dart';

import 'package:apex/features/assistente/presentation/screens/assistente_screen.dart';
import 'package:apex/features/guida/presentation/screens/guida_screen.dart';
import 'package:apex/features/home/presentation/screens/home_screen.dart';
import 'package:apex/features/profilo/presentation/screens/profilo_screen.dart';
import 'package:apex/features/segnalazioni/presentation/screens/segnalazioni_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static const List<AppTab> _tabs = [
    AppTab(
      label: 'Home',
      icon: Icons.home_filled,
      screen: HomeScreen(),
    ),
    AppTab(
      label: 'Segnalazioni',
      icon: Icons.report_problem,
      screen: SegnalazioniScreen(),
    ),
    AppTab(
      label: 'Assistente',
      icon: Icons.support_agent,
      screen: AssistenteScreen(),
    ),
    AppTab(
      label: 'Guida',
      icon: Icons.explore,
      screen: GuidaScreen(),
    ),
    AppTab(
      label: 'Profilo',
      icon: Icons.person_outline,
      screen: ProfiloScreen(),
    ),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs.map((tab) => tab.screen).toList(),
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Theme.of(context).colorScheme.primaryContainer,
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTap,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          destinations: _tabs
              .map(
                (tab) => NavigationDestination(
                  icon: Icon(tab.icon),
                  label: tab.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class AppTab {
  final String label;
  final IconData icon;
  final Widget screen;

  const AppTab({
    required this.label,
    required this.icon,
    required this.screen,
  });
}
