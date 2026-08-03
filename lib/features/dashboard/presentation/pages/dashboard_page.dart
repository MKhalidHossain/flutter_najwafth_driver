import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/core/core.dart';
import 'package:flutter_najwafth_driver/features/dashboard/presentation/pages/tabs/active_tab.dart';
import 'package:flutter_najwafth_driver/features/dashboard/presentation/pages/tabs/history_tab.dart';
import 'package:flutter_najwafth_driver/features/dashboard/presentation/pages/tabs/home_tab.dart';
import 'package:flutter_najwafth_driver/features/dashboard/presentation/pages/tabs/profile_tab.dart';
import 'package:flutter_najwafth_driver/features/driver_requests/application/driver_request_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    HomeTab(),
    ActiveTab(),
    HistoryTab(),
    ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    ref.listenManual(driverRequestEventProvider, (previous, next) {
      if (next == null || !mounted) return;

      if (next.type == 'driver_request_accepted') {
        setState(() => _currentIndex = 1);
      } else if (next.type == 'driver_request_assigned' ||
          next.type == 'driver_request_new') {
        setState(() => _currentIndex = 0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.subtitle,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: context.l10n.tr('Home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.list_alt),
            label: context.l10n.tr('Active'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: context.l10n.tr('History'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: context.l10n.tr('Profile'),
          ),
        ],
      ),
    );
  }
}
