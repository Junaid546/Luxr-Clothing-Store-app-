import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:style_cart/app/router/app_router.dart';
import 'package:style_cart/app/theme/app_theme.dart';
import 'package:style_cart/features/notifications/data/providers/notification_providers.dart';
import 'package:style_cart/features/notifications/presentation/widgets/in_app_notification_banner.dart';

class StyleCartApp extends ConsumerWidget {
  const StyleCartApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    // Initialize FCM (watches auth state)
    ref.watch(fcmInitializerProvider);

    return InAppNotificationBanner(
      child: MaterialApp.router(
        title: 'StyleCart',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: router,
        builder: (context, child) {
          // Ensure the app takes full screen and proper MediaQuery settings
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.noScaling),
            child: child ?? const SizedBox.expand(),
          );
        },
      ),
    );
  }
}
