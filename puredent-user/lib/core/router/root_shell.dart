import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shared bottom-nav shell for the 4 primary tabs. Each tab keeps its own
/// Navigator via [StatefulNavigationShell] so switching tabs preserves each
/// tab's scroll position / state instead of rebuilding from scratch.
class RootShell extends StatelessWidget {
  const RootShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.medical_services_outlined), selectedIcon: Icon(Icons.medical_services_rounded), label: 'Services'),
          NavigationDestination(
              icon: Icon(Icons.groups_outlined), selectedIcon: Icon(Icons.groups_rounded), label: 'Doctors'),
          NavigationDestination(
              icon: Icon(Icons.event_note_outlined), selectedIcon: Icon(Icons.event_note_rounded), label: 'Appointments'),
        ],
      ),
    );
  }
}
