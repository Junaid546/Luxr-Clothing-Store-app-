import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:style_cart/app/router/route_names.dart';
import 'package:style_cart/app/theme/app_colors.dart';
import 'package:style_cart/app/theme/app_dimensions.dart';
import 'package:style_cart/app/theme/app_text_styles.dart';
import 'package:style_cart/features/auth/presentation/providers/auth_state_notifier.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleSendReset() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authNotifierProvider.notifier)
        .sendPasswordReset(_emailController.text.trim());

    if (success && mounted) {
      setState(() => _emailSent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;

    ref.listen(authNotifierProvider, (previous, next) {
      if (next is AuthError) {
        _showError(next.message);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: _emailSent ? _buildSuccessState() : _buildFormState(isLoading),
      ),
    );
  }

  Widget _buildFormState(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacing24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: AppDimensions.spacing48),

            // Lock icon
            const Icon(Icons.lock_outline, size: 80, color: AppColors.gold),
            const SizedBox(height: AppDimensions.spacing32),

            // Title
            const Text('Reset Password', style: AppTextStyles.displayMedium),
            const SizedBox(height: AppDimensions.spacing16),

            // Subtitle
            Text(
              "Enter your email and we'll send you a reset link",
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacing32),

            // Email field
            const Text('EMAIL ADDRESS', style: AppTextStyles.labelSmall),
            const SizedBox(height: AppDimensions.spacing8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.backgroundCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radius12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radius12),
                  borderSide: const BorderSide(color: AppColors.borderDefault),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radius12),
                  borderSide: const BorderSide(color: AppColors.borderActive),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.spacing32),

            // Send button
            SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleSendReset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusPill,
                    ),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'SEND RESET LINK',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 100,
              color: AppColors.successTeal,
            ),
            const SizedBox(height: AppDimensions.spacing32),
            const Text('Email Sent!', style: AppTextStyles.displayMedium),
            const SizedBox(height: AppDimensions.spacing16),
            Text(
              'Check your inbox for the reset link.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacing48),
            OutlinedButton(
              onPressed: () => context.go(RouteNames.login),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.borderDefault),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing32,
                  vertical: AppDimensions.spacing16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                ),
              ),
              child: const Text(
                'BACK TO SIGN IN',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
