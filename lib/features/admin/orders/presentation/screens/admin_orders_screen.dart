import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:style_cart/app/theme/app_colors.dart';
import 'package:style_cart/app/theme/app_text_styles.dart';
import 'package:style_cart/features/admin/core/providers/admin_guard_provider.dart';
import 'package:style_cart/features/admin/orders/presentation/providers/admin_order_notifier.dart';
import 'package:style_cart/features/admin/orders/presentation/widgets/admin_order_card.dart';
import 'package:style_cart/features/admin/orders/presentation/widgets/status_update_dialog.dart';
import 'package:style_cart/features/orders/domain/entities/order_entity.dart';
import 'package:style_cart/core/constants/firestore_schema.dart';

class AdminOrdersScreen extends ConsumerWidget with AdminGuardMixin {
  const AdminOrdersScreen({super.key});

  @override
  Widget buildAdmin(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminOrderNotifierProvider);
    final notifier = ref.read(adminOrderNotifierProvider.notifier);

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundDark,
          elevation: 0,
          title: Text(
            'Order Management',
            style: AppTextStyles.headlineMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            onTap: (index) {
              final status = _getStatusFromIndex(index);
              notifier.setTab(status);
            },
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Pending'),
              Tab(text: 'Processing'),
              Tab(text: 'Shipped'),
              Tab(text: 'Delivered'),
              Tab(text: 'Returned'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextFormField(
                onChanged: notifier.setSearchQuery,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search by Order ID or Email',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.backgroundCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Order List
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.hasError
                      ? _buildErrorPlaceholder(state.errorMessage, notifier)
                      : _buildOrderList(context, ref, notifier),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, WidgetRef ref, AdminOrderNotifier notifier) {
    final orders = notifier.filteredOrders;

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            const Text(
              'No orders found',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => notifier.refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return AdminOrderCard(
            order: order,
            onTap: () {
              // Navigate to tracking/details screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Viewing order #${order.orderId}')),
              );
            },
            onUpdateStatus: (nextStatus) => _onUpdateStatus(context, order, nextStatus, notifier),
          );
        },
      ),
    );
  }

  void _onUpdateStatus(BuildContext context, OrderEntity order, String nextStatus, AdminOrderNotifier notifier) {
    showDialog<void>(
      context: context,
      builder: (context) => StatusUpdateDialog(
        order: order,
        nextStatus: nextStatus,
        onConfirm: (note, courier) async {
          final result = await notifier.updateStatus(
            orderId: order.orderId,
            status: nextStatus,
            note: note,
            courier: courier,
          );

          if (!context.mounted) return;
          result.fold(
            (l) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${l.message}')),
            ),
            (r) => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Order Status Updated Successfully')),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorPlaceholder(String error, AdminOrderNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(error, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => notifier.refresh(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _getStatusFromIndex(int index) {
    return switch (index) {
      0 => 'all',
      1 => OrderStatus.pending,
      2 => OrderStatus.processing,
      3 => OrderStatus.shipped,
      4 => OrderStatus.delivered,
      5 => OrderStatus.returned,
      _ => 'all',
    };
  }
}
