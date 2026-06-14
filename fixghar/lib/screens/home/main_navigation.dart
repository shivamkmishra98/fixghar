import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../booking/booking_history_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../provider/provider_panel_screen.dart';

/// Root scaffold with a bottom navigation bar
/// Shows different tabs based on the user's role (customer vs provider)
class MainNavigation extends StatefulWidget {
  /// Optional initial tab index (e.g. pass 1 to open Bookings directly)
  final int initialIndex;

  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isProvider = authProvider.currentUser?.role == 'provider';

    // Screens differ by user role
    const customerScreens = [
      HomeScreen(),
      BookingHistoryScreen(),
      ProfileScreen(),
    ];

    const providerScreens = [
      ProviderPanelScreen(), // Provider sees their dashboard first
      BookingHistoryScreen(),
      ProfileScreen(),
    ];

    final screens = isProvider ? providerScreens : customerScreens;

    return Scaffold(
      body: IndexedStack(
        // IndexedStack preserves scroll position across tab switches
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: AppColors.bottomNavBackground,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        elevation: 12,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home_rounded),
            label: isProvider ? 'Dashboard' : AppStrings.home,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long_rounded),
            label: AppStrings.bookings,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: AppStrings.profile,
          ),
        ],
      ),
    );
  }
}
