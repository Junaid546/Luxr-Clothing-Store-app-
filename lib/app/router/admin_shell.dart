import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_colors.dart';
import 'route_names.dart';

class AdminShell extends ConsumerWidget {
  final Widget child;
  const AdminShell({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(body: child, bottomNavigationBar: _buildBottomNav(context));
  }

  Widget _buildBottomNav(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    int currentIndex = 0;
    if (location.startsWith('/admin')) {
      if (location == '/admin') {
        currentIndex = 0;
      } else if (location.contains('/products')) {
        currentIndex = 1;
      } else if (location.contains('/orders')) {
        currentIndex = 2;
      } else if (location.contains('/analytics')) {
        currentIndex = 3;
      }
    }

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go(RouteNames.adminDashboard);
            break;
          case 1:
            context.go(RouteNames.adminProducts);
            break;
          case 2:
            context.go(RouteNames.adminOrders);
            break;
          case 3:
            context.go(RouteNames.adminAnalytics);
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.backgroundCard,
      selectedItemColor: AppColors.gold,
      unselectedItemColor: AppColors.textMuted,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          activeIcon: Icon(Icons.inventory_2),
          label: 'Products',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined),
          activeIcon: Icon(Icons.analytics),
          label: 'Analytics',
        ),
      ],
    );
  }
}
