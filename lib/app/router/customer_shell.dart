import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:style_cart/app/theme/app_colors.dart';
import 'package:style_cart/app/router/route_names.dart';
import 'package:style_cart/core/providers/shared_providers.dart';

class NavTab {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const NavTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}

class CustomerShell extends ConsumerWidget {
  const CustomerShell({required this.child, super.key});
  final Widget child;

  static const _tabs = [
    NavTab(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'HOME',
      route: RouteNames.home,
    ),
    NavTab(
      icon: Icons.search_outlined,
      activeIcon: Icons.search,
      label: 'SHOP',
      route: RouteNames.shop,
    ),
    NavTab(
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag,
      label: 'CART',
      route: RouteNames.cart,
    ),
    NavTab(
      icon: Icons.favorite_border,
      activeIcon: Icons.favorite,
      label: 'WISHLIST',
      route: RouteNames.wishlist,
    ),
    NavTab(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'PROFILE',
      route: RouteNames.profile,
    ),
  ];

  int _getActiveIndex(String location) {
    if (location.startsWith('/shop') || location.startsWith('/product')) {
      return 1;
    }
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
      extendBody: true, // Allow body to extend behind the floating bar
      body: child,
      bottomNavigationBar: _FloatingNavBar(
        activeIndex: activeIndex,
        onTap: (index) => context.go(_tabs[index].route),
        tabs: _tabs,
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final int activeIndex;
  final void Function(int) onTap;
  final List<NavTab> tabs;

  const _FloatingNavBar({
    required this.activeIndex,
    required this.onTap,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      height: 70,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(
                color: AppColors.gold.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(tabs.length, (index) {
                final tab = tabs[index];
                final isActive = activeIndex == index;

                return _NavBarItem(
                  tab: tab,
                  isActive: isActive,
                  onTap: () => onTap(index),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends ConsumerWidget {
  final NavTab tab;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCart = tab.label == 'CART';
    final countAsync = isCart ? ref.watch(cartItemCountProvider) : null;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.gold.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive ? tab.activeIcon : tab.icon,
                  color: isActive ? AppColors.gold : AppColors.textSecondary,
                  size: 26,
                ),
                if (isCart)
                  countAsync!.when(
                    data: (count) {
                      if (count == 0) return const SizedBox.shrink();
                      return Positioned(
                        right: -5,
                        top: -5,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.gold,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
              ],
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
