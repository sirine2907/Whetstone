import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/nav_provider.dart';
import 'settings_screen.dart';
import 'sharpen_screen.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavProvider>();

    const screens = [
      SharpenScreen(),
      Center(child: Text('Templates')),
      Center(child: Text('History')),
      SettingsScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        // On a wide window the content stays a readable width.
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: IndexedStack(index: nav.index, children: screens),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: nav.index,
        onDestinationSelected: nav.goTo,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.auto_fix_normal_outlined), selectedIcon: Icon(Icons.auto_fix_normal), label: 'Sharpen'),
          NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view_rounded), label: 'Templates'),
          NavigationDestination(icon: Icon(Icons.history), selectedIcon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.tune_outlined), selectedIcon: Icon(Icons.tune), label: 'Settings'),
        ],
      ),
    );
  }
}
