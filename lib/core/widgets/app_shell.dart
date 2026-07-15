import 'package:flutter/material.dart';
import '../../features/home/home_screen.dart';
import '../../features/doctors/screens/doctors_list_screen.dart';
import '../../features/services/screens/services_list_screen.dart';
import '../../features/bookings/bookings_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../theme/app_colors.dart';

/// The 5 nav destinations are the same across every mockup's
/// <nav class="fixed bottom-0 ..."> bar: Home, Doctors, Services,
/// Bookings, Profile. This widget owns the IndexedStack + BottomNavigationBar
/// so each tab keeps its own scroll/state when you switch away and back.
class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index = widget.initialIndex;

  static const _tabs = [
    HomeScreen(),
    DoctorsListScreen(),
    ServicesListScreen(),
    BookingsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), activeIcon: Icon(Icons.groups), label: 'Doctors'),
          BottomNavigationBarItem(icon: Icon(Icons.medical_services_outlined), activeIcon: Icon(Icons.medical_services), label: 'Services'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), activeIcon: Icon(Icons.calendar_month), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      backgroundColor: AppColors.background,
    );
  }
}
