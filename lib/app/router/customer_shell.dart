import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:style_cart/app/theme/app_colors.dart';
import 'package:style_cart/app/router/route_names.dart';
import 'package:style_cart/app/router/app_router.dart';

class CustomerShell extends ConsumerWidget {
  const CustomerShell({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNav(context, ref),
    );
  }

  Widget _buildBottomNav(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final cartCount = ref.watch(cartItemCountProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(top: BorderSide(color: Color(0x1AFFFFFF))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(context, Icons.home_outlined, Icons.home, 0, location.startsWith('/home')),
            _buildNavItem(context, Icons.search_outlined, Icons.search, 1, location.startsWith('/shop')),
            _buildNavItem(context, Icons.shopping_bag_outlined, Icons.shopping_bag, 2, location.startsWith('/cart'), badgeCount: cartCount),
            _buildNavItem(context, Icons.favorite_outline, Icons.favorite, 3, location.startsWith('/wishlist')),
            _buildNavItem(context, Icons.person_outline, Icons.person, 4, location.startsWith('/profile')),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, IconData activeIcon, int index, bool isActive, {int badgeCount = 0}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        switch (index) {
          case 0: context.go(RouteNames.home);
          case 1: context.go(RouteNames.shop);
          case 2: context.go(RouteNames.cart);
          case 3: context.go(RouteNames.wishlist);
          case 4: context.go(RouteNames.profile);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Badge(
            isLabelVisible: badgeCount > 0,
            label: Text('$badgeCount'),
            child: Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primary : AppColors.textMuted,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
