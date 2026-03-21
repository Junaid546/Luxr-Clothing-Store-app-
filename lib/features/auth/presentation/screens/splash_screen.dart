import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/auth_state_notifier.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleNavigation(AuthRedirectStatus status) async {
    if (status == AuthRedirectStatus.loading) return;

    final destination = switch (status) {
      AuthRedirectStatus.admin => RouteNames.adminDashboard,
      AuthRedirectStatus.customer => RouteNames.home,
      AuthRedirectStatus.unauthenticated => RouteNames.login,
      AuthRedirectStatus.loading => null,
    };

    if (destination != null && mounted) {
      // Ensure splash shows for at least 2 seconds
      await Future<void>.delayed(const Duration(seconds: 2));
      if (mounted) {
        context.go(destination);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch status to handle navigation on build if already loaded
    final status = ref.watch(authRedirectStatusProvider);

    // Listen to auth state changes for navigation
    ref.listen(authRedirectStatusProvider, (previous, next) {
      _handleNavigation(next);
    });

    // Handle initial navigation if state is already determined
    if (status != AuthRedirectStatus.loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleNavigation(status);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SizedBox.expand(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Animated Logo
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Gold horizontal rule above
                      Container(
                        width: 120,
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.gold.withValues(alpha: 0),
                              AppColors.gold.withValues(alpha: 0.6),
                              AppColors.gold.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacing24),
                      // Logo text
                      Text(
                        'LUXR',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontStyle: FontStyle.italic,
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacing8),
                      // Gold horizontal rule below
                      Container(
                        width: 120,
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.gold.withValues(alpha: 0),
                              AppColors.gold.withValues(alpha: 0.6),
                              AppColors.gold.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacing24),
                      // Subtitle
                      Text(
                        'PREMIUM FASHION',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.gold,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 1),
              // Loading indicator
              Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spacing48),
                child: Column(
                  children: [
                    SizedBox(
                      width: 200,
                      height: 1,
                      child: LinearProgressIndicator(
                        backgroundColor: AppColors.gold.withValues(alpha: 0.2),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.gold),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacing16),
                    Text(
                      'LOADING EXCELLENCE',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.gold.withValues(alpha: 0.6),
                        letterSpacing: 3,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
