abstract final class RouteNames {
  // Auth
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Customer shell (bottom nav)
  static const String home = '/home';
  static const String shop = '/shop';
  static const String productDetail = '/product/:productId';
  static const String cart = '/cart';
  static const String wishlist = '/wishlist';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String notificationPreferences = '/notification-preferences';

  // Checkout flow
  static const String checkout = '/checkout';
  static const String orderConfirmation = '/order-confirmation/:orderId';
  static const String orderTracking = '/order-tracking/:orderId';
  static const String myOrders = '/my-orders';

  // Admin shell (separate nav)
  static const String adminDashboard = '/admin';
  static const String adminProducts = '/admin/products';
  static const String adminAddProduct = '/admin/products/add';
  static const String adminEditProduct = '/admin/products/:productId/edit';
  static const String adminOrders = '/admin/orders';
  static const String adminOrderDetail = '/admin/orders/:orderId';
  static const String adminAnalytics = '/admin/analytics';
  static const String adminSendNotification = '/admin/notifications/send';

  // Descriptive Names for goNamed
  static const String orderConfirmationName = 'order_confirmation';
  static const String orderTrackingName = 'order_tracking';
  static const String productDetailName = 'product_detail';
}
