import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:style_cart/app/theme/app_colors.dart';
import 'package:style_cart/app/theme/app_text_styles.dart';
import 'package:style_cart/features/admin/core/providers/admin_guard_provider.dart';

class AdminOrdersScreen extends ConsumerWidget with AdminGuardMixin {
  const AdminOrdersScreen({super.key});

  @override
  Widget buildAdmin(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Orders Management', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.gold.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'Order Management Coming Soon',
              style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Process returns and track shipments here.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
