import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stylecart/app/router/route_names.dart';
import 'package:stylecart/app/theme/app_colors.dart';
import 'package:stylecart/app/theme/app_text_styles.dart';
import 'package:stylecart/core/utils/extensions.dart';
import 'package:stylecart/features/cart/data/models/cart_item_model.dart';
import 'package:stylecart/features/cart/domain/entities/cart_entity.dart';
import 'package:stylecart/features/cart/presentation/providers/cart_notifier.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItemsAsync = ref.watch(cartItemsProvider);
    final summary = ref.watch(cartTotalProvider);
    final isUpdating = ref.watch(cartNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: cartItemsAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return const _EmptyCartView();
            }
            return Column(
              children: [
                _CartAppBar(summary: summary),
                Expanded(
                  child: ListView(
                    children: [
                      // Cart items list
                      ...items.map(
                        (item) =>
                            _CartItemCard(item: item, isUpdating: isUpdating),
                      ),
                      const SizedBox(height: 12),
                      // Order summary card
                      _OrderSummaryCard(summary: summary),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
                // Fixed bottom checkout button
                _CheckoutBar(isEmpty: items.isEmpty),
              ],
            );
          },
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.gold)),
          error: (e, _) => Center(
              child:
                  Text('Error: $e', style: const TextStyle(color: Colors.red))),
        ),
      ),
    );
  }
}

class _CartAppBar extends ConsumerWidget {
  final CartSummary summary;
  const _CartAppBar({required this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go(RouteNames.shop),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('My Cart',
                  style: AppTextStyles.headlineMedium.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              Text(
                '${summary.subtotal > 0 ? (summary.total / 10).toInt() : 0} ITEMS', // Estimation or replace with actual totalItems if added to summary
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Clear all button
          GestureDetector(
            onTap: () => _showClearCartDialog(context, ref),
            child: const Icon(
              Icons.delete_sweep_outlined,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends ConsumerWidget {
  final CartItemModel item;
  final bool isUpdating;

  const _CartItemCard({required this.item, required this.isUpdating});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartNotifier = ref.read(cartNotifierProvider.notifier);

    return Dismissible(
      key: Key(item.cartItemId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) async {
        return await _showRemoveDialog(context, item.productName);
      },
      onDismissed: (_) => cartNotifier.removeFromCart(item.cartItemId),
      child: _CartItemContent(item: item, isUpdating: isUpdating),
    );
  }
}

class _CartItemContent extends ConsumerWidget {
  final CartItemModel item;
  final bool isUpdating;

  const _CartItemContent({required this.item, required this.isUpdating});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartNotifier = ref.read(cartNotifierProvider.notifier);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              width: 80,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  item.productName,
                  style: AppTextStyles.titleMedium.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Size + Color
                Text(
                  'Size: ${item.size} | Color: ${item.color}',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 8),
                // Price + Quantity row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.finalPrice.toCurrencyString,
                          style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold),
                        ),
                        if (item.discountPct > 0)
                          Text(
                            item.unitPrice.toCurrencyString,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textMuted,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                    // Quantity stepper
                    _QuantityStepper(
                      quantity: item.quantity,
                      onDecrement: () => cartNotifier.updateQuantity(
                        item.cartItemId,
                        item.quantity - 1,
                      ),
                      onIncrement: () => cartNotifier.updateQuantity(
                        item.cartItemId,
                        item.quantity + 1,
                      ),
                      isLoading: isUpdating,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Remove button (top right)
          GestureDetector(
            onTap: () async {
              final confirmed =
                  await _showRemoveDialog(context, item.productName);
              if (confirmed == true) {
                cartNotifier.removeFromCart(item.cartItemId);
              }
            },
            child: const Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(bottom: 50),
                child: Icon(
                  Icons.close,
                  color: AppColors.textMuted,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final bool isLoading;

  const _QuantityStepper({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove,
            onTap: isLoading ? null : onDecrement,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: isLoading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Text('$quantity',
                    style: AppTextStyles.titleMedium
                        .copyWith(color: Colors.white)),
          ),
          _StepButton(
            icon: Icons.add,
            onTap: isLoading ? null : onIncrement,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final CartSummary summary;
  const _OrderSummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'Subtotal',
            value: summary.subtotal.toCurrencyString,
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Shipping',
            value: summary.shippingCost == 0.0
                ? 'FREE'
                : summary.shippingCost.toCurrencyString,
            valueColor:
                summary.shippingCost == 0.0 ? AppColors.success : Colors.white,
          ),
          if (summary.discountAmount > 0) ...[
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Discount',
              value: '-${summary.discountAmount.toCurrencyString}',
              valueColor: AppColors.success,
            ),
          ],
          if (summary.totalSavings > 0) ...[
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'You save',
              value: summary.totalSavings.toCurrencyString,
              valueColor: AppColors.successTeal,
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              color: AppColors.borderDefault,
              thickness: 1,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total',
                  style: AppTextStyles.titleLarge.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              Text(
                summary.total.toCurrencyString,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          // Free shipping progress bar
          if (!summary.freeShippingEligible) ...[
            const SizedBox(height: 16),
            _FreeShippingProgress(
              currentAmount: summary.subtotal,
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
        Text(value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: valueColor ?? Colors.white,
              fontWeight: FontWeight.w500,
            )),
      ],
    );
  }
}

class _FreeShippingProgress extends StatelessWidget {
  final double currentAmount;
  const _FreeShippingProgress({required this.currentAmount});

  @override
  Widget build(BuildContext context) {
    final threshold = double.parse(
      dotenv.env['FREE_SHIPPING_THRESHOLD'] ?? '100',
    );
    final remaining = threshold - currentAmount;
    final progress = currentAmount / threshold;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add \$${remaining.toStringAsFixed(2)} more for FREE shipping',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: AppColors.backgroundElevated,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.successTeal,
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  final bool isEmpty;
  const _CheckoutBar({required this.isEmpty});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(
          top: BorderSide(color: AppColors.borderDefault),
        ),
      ),
      child: ElevatedButton(
        onPressed:
            isEmpty ? null : () => context.pushNamed(RouteNames.checkout),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Proceed to Checkout',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_bag_outlined,
              size: 80, color: AppColors.textMuted),
          const SizedBox(height: 20),
          Text('Your cart is empty',
              style: AppTextStyles.titleLarge
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text('Add items to get started',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go(RouteNames.shop),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
            ),
            child: const Text('Start Shopping'),
          ),
        ],
      ),
    );
  }
}

Future<bool?> _showRemoveDialog(BuildContext context, String productName) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.backgroundElevated,
      title: const Text('Remove Item?', style: TextStyle(color: Colors.white)),
      content: Text('Remove $productName from your cart?',
          style: const TextStyle(color: AppColors.textSecondary)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('CANCEL',
              style: TextStyle(color: AppColors.textMuted)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('REMOVE', style: TextStyle(color: AppColors.error)),
        ),
      ],
    ),
  );
}

void _showClearCartDialog(BuildContext context, WidgetRef ref) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.backgroundElevated,
      title: const Text('Clear Cart?', style: TextStyle(color: Colors.white)),
      content: const Text(
          'Are you sure you want to remove all items from your cart?',
          style: TextStyle(color: AppColors.textSecondary)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL',
              style: TextStyle(color: AppColors.textMuted)),
        ),
        TextButton(
          onPressed: () {
            ref.read(cartNotifierProvider.notifier).clearCart();
            Navigator.pop(context);
          },
          child:
              const Text('CLEAR ALL', style: TextStyle(color: AppColors.error)),
        ),
      ],
    ),
  );
}
