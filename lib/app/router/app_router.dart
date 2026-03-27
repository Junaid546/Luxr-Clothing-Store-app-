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
import 'package:style_cart/features/products/presentation/screens/product_detail_screen.dart';
import 'package:style_cart/features/wishlist/presentation/screens/wishlist_screen.dart';
import 'package:style_cart/features/cart/presentation/screens/cart_screen.dart';
import 'package:style_cart/features/profile/presentation/screens/profile_screen.dart';
import 'package:style_cart/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:style_cart/features/orders/presentation/screens/order_confirmation_screen.dart';
import 'package:style_cart/features/orders/presentation/screens/my_orders_screen.dart';
import 'package:style_cart/features/orders/presentation/screens/order_tracking_screen.dart';
import 'package:style_cart/features/admin/dashboard/presentation/screens/admin_dashboard_screen.dart';
import 'package:style_cart/features/admin/products/presentation/screens/admin_products_screen.dart';
import 'package:style_cart/features/admin/products/presentation/screens/add_edit_product_screen.dart';
import 'package:style_cart/features/admin/orders/presentation/screens/admin_orders_screen.dart';
import 'package:style_cart/features/admin/analytics/presentation/screens/admin_analytics_screen.dart';
import 'package:style_cart/features/notifications/presentation/screens/notification_center_screen.dart';
import 'package:style_cart/features/notifications/presentation/screens/notification_preferences_screen.dart';
import 'package:style_cart/features/admin/notifications/presentation/screens/admin_send_notification_screen.dart';

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
            name: RouteNames.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: RouteNames.shop,
            name: RouteNames.shop,
            builder: (context, state) => const ShopScreen(),
          ),
          GoRoute(
            path: RouteNames.cart,
            name: RouteNames.cart,
            builder: (context, state) => const CartScreen(),
          ),
          GoRoute(
            path: RouteNames.productDetail,
            name: RouteNames.productDetailName,
            builder: (context, state) {
              final productId = state.pathParameters['productId']!;
              return ProductDetailScreen(productId: productId);
            },
          ),
          GoRoute(
            path: RouteNames.wishlist,
            name: RouteNames.wishlist,
            builder: (context, state) => const WishlistScreen(),
          ),
          GoRoute(
            path: RouteNames.notifications,
            name: RouteNames.notifications,
            builder: (context, state) => const NotificationCenterScreen(),
          ),
          GoRoute(
            path: RouteNames.profile,
            name: RouteNames.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: RouteNames.notificationPreferences,
            name: RouteNames.notificationPreferences,
            builder: (context, state) => const NotificationPreferencesScreen(),
          ),
          GoRoute(
            path: RouteNames.checkout,
            name: RouteNames.checkout,
            builder: (context, state) => const CheckoutScreen(),
          ),
          GoRoute(
            path: RouteNames.orderConfirmation,
            name: RouteNames.orderConfirmationName,
            builder: (context, state) {
              final orderId = state.pathParameters['orderId']!;
              return OrderConfirmationScreen(orderId: orderId);
            },
          ),
          GoRoute(
            path: RouteNames.myOrders,
            name: RouteNames.myOrders,
            builder: (context, state) => const MyOrdersScreen(),
          ),
          GoRoute(
            path: RouteNames.orderTracking,
            name: RouteNames.orderTrackingName,
            builder: (context, state) {
              final orderId = state.pathParameters['orderId']!;
              return OrderTrackingScreen(orderId: orderId);
            },
          ),
        ],
      ),

      // Admin shell routes
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.adminDashboard,
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: RouteNames.adminProducts,
            builder: (context, state) => const AdminProductsScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddEditProductScreen(),
              ),
              GoRoute(
                path: ':productId/edit',
                builder: (context, state) {
                  final productId = state.pathParameters['productId']!;
                  return AddEditProductScreen(productId: productId);
                },
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.adminOrders,
            builder: (context, state) => const AdminOrdersScreen(),
            routes: [
              GoRoute(
                path: ':orderId',
                builder: (context, state) {
                  final orderId = state.pathParameters['orderId']!;
                  return OrderTrackingScreen(orderId: orderId);
                },
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.adminAnalytics,
            builder: (context, state) => const AdminAnalyticsScreen(),
          ),
          GoRoute(
            path: RouteNames.adminSendNotification,
            builder: (context, state) => const AdminSendNotificationScreen(),
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
  final location = state.matchedLocation;

  // 1. Define sets of routes for easier checking
  final isAuthRoute = [
    RouteNames.splash,
    RouteNames.login,
    RouteNames.register,
    RouteNames.forgotPassword,
  ].contains(location);

  final isPublicRoute = [
    RouteNames.home,
    RouteNames.shop,
  ].contains(location) || location.startsWith('/product/');


  // 2. Routing logic based on Auth Status
  return switch (status) {
    AuthRedirectStatus.loading => RouteNames.splash,

    // Unauthenticated: must go to login for protected routes
    AuthRedirectStatus.unauthenticated =>
      (isAuthRoute || isPublicRoute) ? null : RouteNames.login,

    // Customer OR Admin: allow all navigation, screen-level guards handle admin access
    AuthRedirectStatus.customer || AuthRedirectStatus.admin =>
      isAuthRoute ? RouteNames.home : null,
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
