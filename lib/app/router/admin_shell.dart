import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:style_cart/app/theme/app_colors.dart';
import 'package:style_cart/app/router/route_names.dart';

class AdminShell extends ConsumerWidget {
  const AdminShell({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(body: child, bottomNavigationBar: _buildBottomNav(context));
  }

  Widget _buildBottomNav(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    var currentIndex = 0;
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
          case 1:
            context.go(RouteNames.adminProducts);
          case 2:
            context.go(RouteNames.adminOrders);
          case 3:
            context.go(RouteNames.adminAnalytics);
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
