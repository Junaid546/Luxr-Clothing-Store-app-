import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:style_cart/app/theme/app_colors.dart';
import 'package:style_cart/app/router/route_names.dart';
import 'package:style_cart/core/providers/shared_providers.dart';

class CustomerShell extends ConsumerWidget {
  const CustomerShell({required this.child, super.key});
  final Widget child;

  static final _tabs = [
    (
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'HOME',
      route: RouteNames.home
    ),
    (
      icon: Icons.search_outlined,
      activeIcon: Icons.search,
      label: 'SHOP',
      route: RouteNames.shop
    ),
    (
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag,
      label: 'CART',
      route: RouteNames.cart
    ),
    (
      icon: Icons.favorite_border,
      activeIcon: Icons.favorite,
      label: 'WISHLIST',
      route: RouteNames.wishlist
    ),
    (
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'PROFILE',
      route: RouteNames.profile
    ),
  ];

  int _getActiveIndex(String location) {
    if (location.startsWith('/shop') || location.startsWith('/product')) return 1;
    if (location.startsWith('/cart')) return 2;
    if (location.startsWith('/wishlist')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0; // home
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final activeIndex = _getActiveIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: activeIndex,
        onTap: (index) => context.go(_tabs[index].route),
        backgroundColor: AppColors.backgroundCard,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        selectedLabelStyle: const TextStyle(fontSize: 10, letterSpacing: 0.5),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        elevation: 0,
        items: _tabs.asMap().entries.map((entry) {
          final tab = entry.value;
          final isCart = tab.label == 'CART';
          return BottomNavigationBarItem(
            icon: isCart
                ? _CartIconWithBadge(
                    icon: tab.icon,
                    isActive: activeIndex == entry.key,
                  )
                : Icon(tab.icon),
            activeIcon: isCart
                ? _CartIconWithBadge(
                    icon: tab.activeIcon,
                    isActive: true,
                  )
                : Icon(tab.activeIcon),
            label: tab.label,
          );
        }).toList(),
      ),
    );
  }
}

class _CartIconWithBadge extends ConsumerWidget {
  final IconData icon;
  final bool isActive;

  const _CartIconWithBadge({required this.icon, required this.isActive});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(cartItemCountProvider);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, color: isActive ? AppColors.primary : AppColors.textMuted),
        countAsync.when(
          data: (count) {
            if (count == 0) return const SizedBox.shrink();
            return Positioned(
              right: -6,
              top: -6,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
