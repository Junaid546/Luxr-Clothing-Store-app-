import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:style_cart/app/router/route_names.dart';
import 'package:style_cart/app/theme/app_colors.dart';

class AdminShell extends ConsumerWidget {
  const AdminShell({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final activeIndex = _getActiveIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundCard,
          border: Border(
            top: BorderSide(
              color: AppColors.borderDefault,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: activeIndex,
          onTap: (index) => context.go(_adminTabs[index].route),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.gold,
          unselectedItemColor: AppColors.textMuted,
          selectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 10,
          ),
          items: _adminTabs
              .map(
                (tab) => BottomNavigationBarItem(
                  icon: Icon(tab.icon),
                  activeIcon: Icon(tab.activeIcon),
                  label: tab.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  int _getActiveIndex(String location) {
    if (location.startsWith(RouteNames.adminProducts)) return 1;
    if (location.startsWith(RouteNames.adminOrders)) return 2;
    if (location.startsWith(RouteNames.adminAnalytics)) return 3;
    return 0; // dashboard
  }
}

// Admin tab definitions
final _adminTabs = [
  (
    icon: Icons.grid_view_outlined,
    activeIcon: Icons.grid_view,
    label: 'DASHBOARD',
    route: RouteNames.adminDashboard,
  ),
  (
    icon: Icons.inventory_2_outlined,
    activeIcon: Icons.inventory_2,
    label: 'PRODUCTS',
    route: RouteNames.adminProducts,
  ),
  (
    icon: Icons.shopping_bag_outlined,
    activeIcon: Icons.shopping_bag,
    label: 'ORDERS',
    route: RouteNames.adminOrders,
  ),
  (
    icon: Icons.bar_chart_outlined,
    activeIcon: Icons.bar_chart,
    label: 'ANALYTICS',
    route: RouteNames.adminAnalytics,
  ),
];
