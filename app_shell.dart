import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/theme.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: appColors.glassBorder),
          ),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) =>
              navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
          backgroundColor: Theme.of(context).colorScheme.surface,
          indicatorColor: appColors.neonAccent.withOpacity(AppTheme.opacityGlass * 2),
          height: 64,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined, color: appColors.subtleText),
              selectedIcon: Icon(Icons.auto_awesome, color: appColors.neonAccent),
              label: 'Generate',
            ),
            NavigationDestination(
              icon: Icon(Icons.library_music_outlined, color: appColors.subtleText),
              selectedIcon: Icon(Icons.library_music, color: appColors.neonAccent),
              label: 'Library',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline, color: appColors.subtleText),
              selectedIcon: Icon(Icons.people, color: appColors.neonAccent),
              label: 'Community',
            ),
            NavigationDestination(
              icon: Icon(Icons.psychology_outlined, color: appColors.subtleText),
              selectedIcon: Icon(Icons.psychology, color: appColors.neonAccent),
              label: 'AI Copilot',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: appColors.subtleText),
              selectedIcon: Icon(Icons.person, color: appColors.neonAccent),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
