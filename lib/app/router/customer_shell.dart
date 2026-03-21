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

    var currentIndex = 0;
    if (location.startsWith('/home')) {
      currentIndex = 0;
    } else if (location.startsWith('/shop')) {
      currentIndex = 1;
    } else if (location.startsWith('/cart')) {
      currentIndex = 2;
    } else if (location.startsWith('/wishlist')) {
      currentIndex = 3;
    } else if (location.startsWith('/profile')) {
      currentIndex = 4;
    }

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go(RouteNames.home);
          case 1:
            context.go(RouteNames.shop);
          case 2:
            context.go(RouteNames.cart);
          case 3:
            context.go(RouteNames.wishlist);
          case 4:
            context.go(RouteNames.profile);
        }
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.backgroundCard,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textMuted,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_outlined),
          activeIcon: Icon(Icons.shopping_bag),
          label: 'Shop',
        ),
        BottomNavigationBarItem(
          icon: Badge(
            isLabelVisible: cartCount > 0,
            label: Text('$cartCount'),
            child: const Icon(Icons.shopping_cart_outlined),
          ),
          activeIcon: Badge(
            isLabelVisible: cartCount > 0,
            label: Text('$cartCount'),
            child: const Icon(Icons.shopping_cart),
          ),
          label: 'Cart',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.favorite_outline),
          activeIcon: Icon(Icons.favorite),
          label: 'Wishlist',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
