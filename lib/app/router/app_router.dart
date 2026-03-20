import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'route_names.dart';
import 'customer_shell.dart';
import 'admin_shell.dart';

// Auth status enum (stub for now)
enum AuthStatus { loading, authenticated, unauthenticated }

// Auth state provider (stub)
final authStateProvider = StateProvider<AuthStatus>(
  (ref) => AuthStatus.unauthenticated,
);

// Cart item count provider (stub)
final cartItemCountProvider = StateProvider<int>((ref) => 0);

class AppRouter {
  static final navigatorKey = GlobalKey<NavigatorState>();
}

// Router provider (without code generation)
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: AppRouter.navigatorKey,
    initialLocation: RouteNames.splash,
    redirect: (context, state) => _handleRedirect(authState, state),
    routes: [
      // Auth routes (no shell)
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreenPlaceholder(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreenPlaceholder(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterScreenPlaceholder(),
      ),

      // Customer shell routes
      ShellRoute(
        builder: (context, state, child) => CustomerShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.home,
            builder: (context, state) => const HomeScreenPlaceholder(),
          ),
          GoRoute(
            path: RouteNames.shop,
            builder: (context, state) => const ShopScreenPlaceholder(),
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

String? _handleRedirect(AuthStatus authState, GoRouterState state) {
  final isLoggedIn = authState == AuthStatus.authenticated;
  final isLoggingIn = state.matchedLocation == RouteNames.login;
  final isRegistering = state.matchedLocation == RouteNames.register;
  final isSplash = state.matchedLocation == RouteNames.splash;

  // Allow splash, login, register without auth
  if (isSplash || isLoggingIn || isRegistering) {
    return null;
  }

  // If not logged in, redirect to login
  if (!isLoggedIn) {
    return RouteNames.login;
  }

  return null;
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

class HomeScreenPlaceholder extends StatelessWidget {
  const HomeScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('HomeScreen')));
  }
}

class ShopScreenPlaceholder extends StatelessWidget {
  const ShopScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('ShopScreen')));
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
