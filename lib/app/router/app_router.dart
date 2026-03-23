import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:style_cart/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:style_cart/features/auth/presentation/screens/splash_screen.dart';
import 'package:style_cart/features/auth/presentation/screens/login_screen.dart';
import 'package:style_cart/features/auth/presentation/screens/register_screen.dart';
import 'package:style_cart/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:style_cart/app/router/route_names.dart';
import 'package:style_cart/app/router/customer_shell.dart';
import 'package:style_cart/app/router/admin_shell.dart';
import 'package:style_cart/features/home/presentation/screens/home_screen.dart';
import 'package:style_cart/features/products/presentation/screens/shop_screen.dart';

// Cart item count provider (stub)
final cartItemCountProvider = StateProvider<int>((ref) => 0);

class AppRouter {
  static final navigatorKey = GlobalKey<NavigatorState>();
}

// Router provider
final appRouterProvider = Provider<GoRouter>((ref) {
  final authStatus = ref.watch(authRedirectStatusProvider);

  return GoRouter(
    navigatorKey: AppRouter.navigatorKey,
    initialLocation: RouteNames.splash,
    redirect: (context, state) => _handleRedirect(authStatus, state),
    routes: [
      // Auth routes (no shell)
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Customer shell routes
      ShellRoute(
        builder: (context, state, child) => CustomerShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: RouteNames.shop,
            builder: (context, state) => const ShopScreen(),
          ),
          GoRoute(
            path: RouteNames.cart,
            builder: (context, state) => const CartScreenPlaceholder(),
          ),
          GoRoute(
            path: RouteNames.wishlist,
            builder: (context, state) => const WishlistScreenPlaceholder(),
          ),
          GoRoute(
            path: RouteNames.profile,
            builder: (context, state) => const ProfileScreenPlaceholder(),
          ),
        ],
      ),

      // Admin shell routes
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.adminDashboard,
            builder: (context, state) =>
                const AdminDashboardScreenPlaceholder(),
          ),
          GoRoute(
            path: RouteNames.adminProducts,
            builder: (context, state) => const AdminProductsScreenPlaceholder(),
          ),
          GoRoute(
            path: RouteNames.adminOrders,
            builder: (context, state) => const AdminOrdersScreenPlaceholder(),
          ),
          GoRoute(
            path: RouteNames.adminAnalytics,
            builder: (context, state) =>
                const AdminAnalyticsScreenPlaceholder(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Page not found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.splash),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

String? _handleRedirect(AuthRedirectStatus status, GoRouterState state) {
  final isOnAuthRoute = [
    RouteNames.splash,
    RouteNames.login,
    RouteNames.register,
    RouteNames.forgotPassword,
  ].contains(state.matchedLocation);

  return switch (status) {
    AuthRedirectStatus.loading => RouteNames.splash,
    AuthRedirectStatus.unauthenticated =>
      isOnAuthRoute ? null : RouteNames.login,
    AuthRedirectStatus.customer =>
      isOnAuthRoute
          ? RouteNames.home
          : state.matchedLocation.startsWith('/admin')
          ? RouteNames.home
          : null,
    AuthRedirectStatus.admin =>
      isOnAuthRoute
          ? RouteNames.adminDashboard
          : !state.matchedLocation.startsWith('/admin')
          ? RouteNames.adminDashboard
          : null,
  };
}

// Placeholder screens - will be replaced with actual implementations
class SplashScreenPlaceholder extends StatelessWidget {
  const SplashScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('SplashScreen')));
  }
}

class LoginScreenPlaceholder extends StatelessWidget {
  const LoginScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('LoginScreen')));
  }
}

class RegisterScreenPlaceholder extends StatelessWidget {
  const RegisterScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('RegisterScreen')));
  }
}



class CartScreenPlaceholder extends StatelessWidget {
  const CartScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('CartScreen')));
  }
}

class WishlistScreenPlaceholder extends StatelessWidget {
  const WishlistScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('WishlistScreen')));
  }
}

class ProfileScreenPlaceholder extends StatelessWidget {
  const ProfileScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('ProfileScreen')));
  }
}

class AdminDashboardScreenPlaceholder extends StatelessWidget {
  const AdminDashboardScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('AdminDashboardScreen')));
  }
}

class AdminProductsScreenPlaceholder extends StatelessWidget {
  const AdminProductsScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('AdminProductsScreen')));
  }
}

class AdminOrdersScreenPlaceholder extends StatelessWidget {
  const AdminOrdersScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('AdminOrdersScreen')));
  }
}

class AdminAnalyticsScreenPlaceholder extends StatelessWidget {
  const AdminAnalyticsScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('AdminAnalyticsScreen')));
  }
}
