import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:style_cart/app/router/route_names.dart';
import 'package:style_cart/app/theme/app_colors.dart';
import 'package:style_cart/app/theme/app_text_styles.dart';
import 'package:style_cart/core/constants/firestore_schema.dart';
import 'package:style_cart/features/cart/domain/entities/cart_entity.dart';
import 'package:style_cart/features/cart/presentation/providers/cart_notifier.dart';
import 'package:style_cart/features/checkout/presentation/providers/checkout_notifier.dart';
import 'package:style_cart/features/orders/data/models/order_model.dart';
import 'package:style_cart/features/profile/presentation/providers/profile_providers.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillDefaultAddress();
    });
  }

  Future<void> _prefillDefaultAddress() async {
    try {
      final settings = await ref.read(profileSettingsProvider.future);
      final defaultAddress = settings.defaultAddress;
      if (!mounted || defaultAddress == null) {
        return;
      }

      final checkoutState = ref.read(checkoutNotifierProvider);
      if (checkoutState.selectedAddress != null) {
        return;
      }

      ref
          .read(checkoutNotifierProvider.notifier)
          .setAddress(defaultAddress.toShippingAddress());
    } catch (_) {
      // Keep checkout usable even if profile settings fail to load.
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkoutNotifierProvider);
    final cartItems = ref.watch(cartItemsProvider).value ?? [];

    // Sync handle success
    ref.listen(checkoutNotifierProvider, (prev, next) {
      if (next.successOrderId != null &&
          next.successOrderId != prev?.successOrderId) {
        context.goNamed(
          RouteNames.orderConfirmationName,
          pathParameters: {'orderId': next.successOrderId!},
        );
      }
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            if (state.step == CheckoutStep.address) {
              context.pop();
            } else {
              ref.read(checkoutNotifierProvider.notifier).prevStep();
            }
          },
        ),
        title: Text(
          _getStepTitle(state.step),
          style: AppTextStyles.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const _StepProgressIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStepContent(state),
                    const SizedBox(height: 32),
                    _OrderSummaryCard(
                      summary: CartSummary.compute(
                        items: cartItems,
                        shippingMethod: state.shippingMethod,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomBar(state),
          ],
        ),
      ),
    );
  }

  String _getStepTitle(CheckoutStep step) {
    switch (step) {
      case CheckoutStep.address:
        return 'Shipping Address';
      case CheckoutStep.shipping:
        return 'Shipping Method';
      case CheckoutStep.payment:
        return 'Payment & Review';
    }
  }

  Widget _buildStepContent(CheckoutState state) {
    switch (state.step) {
      case CheckoutStep.address:
        return _AddressStep(selectedAddress: state.selectedAddress);
      case CheckoutStep.shipping:
        return _ShippingStep(selectedMethod: state.shippingMethod);
      case CheckoutStep.payment:
        return _PaymentStep(selectedMethod: state.paymentMethod);
    }
  }

  Widget _buildBottomBar(CheckoutState state) {
    final isLastStep = state.step == CheckoutStep.payment;

    return Container(
      padding: const EdgeInsets.all(20).copyWith(bottom: 30),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: state.isProcessing
                  ? null
                  : () async {
                      final notifier = ref.read(
                        checkoutNotifierProvider.notifier,
                      );
                      if (isLastStep) {
                        await notifier.placeOrder();
                      } else {
                        // Validate before moving to next step
                        if (state.step == CheckoutStep.address) {
                          if (state.selectedAddress == null) return;
                          final ok = await notifier.validateCheckout();
                          if (ok) notifier.nextStep();
                        } else {
                          notifier.nextStep();
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
              ),
              child: state.isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isLastStep ? 'PLACE ORDER' : 'CONTINUE',
                      style: AppTextStyles.labelLarge.copyWith(
                        letterSpacing: 1.2,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepProgressIndicator extends ConsumerWidget {
  const _StepProgressIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStep = ref.watch(checkoutNotifierProvider).step;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: Row(
        children: CheckoutStep.values.map((step) {
          final index = step.index;
          final isCompleted = index < currentStep.index;
          final isCurrent = index == currentStep.index;

          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isCurrent || isCompleted
                        ? AppColors.primary
                        : AppColors.backgroundElevated,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCurrent ? Colors.white : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : Text(
                            '${index + 1}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isCurrent || isCompleted
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                  ),
                ),
                if (index < CheckoutStep.values.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted
                          ? AppColors.primary
                          : AppColors.backgroundElevated,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AddressStep extends ConsumerWidget {
  const _AddressStep({this.selectedAddress});
  final ShippingAddressModel? selectedAddress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Delivering To', style: AppTextStyles.titleLarge),
        const SizedBox(height: 16),
        if (selectedAddress != null)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.backgroundElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedAddress!.fullName,
                  style: AppTextStyles.titleMedium,
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () =>
                          _showAddressForm(context, ref, selectedAddress),
                      child: const Text(
                        'EDIT',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${selectedAddress!.street}\n${selectedAddress!.city}, ${selectedAddress!.state} ${selectedAddress!.zipCode}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  selectedAddress!.phone,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          const Center(child: Text('Please add a shipping address')),
      ],
    );
  }
}

class _ShippingStep extends ConsumerWidget {
  const _ShippingStep({required this.selectedMethod});
  final String selectedMethod;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Choose Shipping', style: AppTextStyles.titleLarge),
        const SizedBox(height: 16),
        _buildMethodCard(
          ref,
          id: ShippingMethod.standard,
          title: 'Standard Delivery',
          info: '3-5 Business Days',
          price: 'Free',
        ),
        const SizedBox(height: 12),
        _buildMethodCard(
          ref,
          id: ShippingMethod.express,
          title: 'Express Delivery',
          info: '1-2 Business Days',
          price: r'$25.00',
        ),
      ],
    );
  }

  Widget _buildMethodCard(
    WidgetRef ref, {
    required String id,
    required String title,
    required String info,
    required String price,
  }) {
    final isSelected = selectedMethod == id;

    return InkWell(
      onTap: () =>
          ref.read(checkoutNotifierProvider.notifier).setShippingMethod(id),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.backgroundElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleMedium),
                  Text(info, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Text(
              price,
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.gold),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentStep extends ConsumerWidget {
  const _PaymentStep({required this.selectedMethod});
  final String selectedMethod;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payment Method', style: AppTextStyles.titleLarge),
        const SizedBox(height: 16),
        _buildPaymentCard(
          ref,
          id: PaymentMethod.cod,
          title: 'Cash on Delivery',
          icon: Icons.money,
        ),
        const SizedBox(height: 12),
        _buildPaymentCard(
          ref,
          id: PaymentMethod.online,
          title: 'Online Payment',
          icon: Icons.credit_card,
          subtitle: 'RazorPay / UPI / Cards',
        ),
        const SizedBox(height: 24),
        const Text('Review Information', style: AppTextStyles.titleLarge),
        const SizedBox(height: 12),
        _buildInfoReview(context, ref),
      ],
    );
  }

  Widget _buildInfoReview(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checkoutNotifierProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          _buildReviewRow(
            Icons.location_on_outlined,
            state.selectedAddress?.formatted ?? '',
          ),
          const Divider(height: 24, color: AppColors.borderDefault),
          _buildReviewRow(
            Icons.local_shipping_outlined,
            state.shippingMethod == ShippingMethod.express
                ? 'Express Delivery'
                : 'Standard Delivery',
          ),
        ],
      ),
    );
  }

  Widget _buildReviewRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentCard(
    WidgetRef ref, {
    required String id,
    required String title,
    IconData? icon,
    String? subtitle,
  }) {
    final isSelected = selectedMethod == id;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: InkWell(
        onTap: () =>
            ref.read(checkoutNotifierProvider.notifier).setPaymentMethod(id),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.backgroundElevated,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.titleMedium),
                    if (subtitle != null)
                      Text(subtitle, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

void _showAddressForm(
  BuildContext context,
  WidgetRef ref, [
  ShippingAddressModel? initial,
]) {
  // Simple dialog for address editing
  final nameCtrl = TextEditingController(text: initial?.fullName);
  final phoneCtrl = TextEditingController(text: initial?.phone);
  final streetCtrl = TextEditingController(text: initial?.street);
  final cityCtrl = TextEditingController(text: initial?.city);

  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.backgroundElevated,
      title: Text(
        initial == null ? 'Add Address' : 'Edit Address',
        style: const TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                labelStyle: TextStyle(color: AppColors.textMuted),
              ),
            ),
            TextField(
              controller: phoneCtrl,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Phone',
                labelStyle: TextStyle(color: AppColors.textMuted),
              ),
            ),
            TextField(
              controller: streetCtrl,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Street',
                labelStyle: TextStyle(color: AppColors.textMuted),
              ),
            ),
            TextField(
              controller: cityCtrl,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => FocusScope.of(context).unfocus(),
              decoration: const InputDecoration(
                labelText: 'City',
                labelStyle: TextStyle(color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: () {
            ref
                .read(checkoutNotifierProvider.notifier)
                .setAddress(
                  ShippingAddressModel(
                    fullName: nameCtrl.text,
                    phone: phoneCtrl.text,
                    street: streetCtrl.text,
                    city: cityCtrl.text,
                    state: initial?.state ?? 'NY',
                    zipCode: initial?.zipCode ?? '10001',
                    country: initial?.country ?? 'USA',
                  ),
                );
            Navigator.pop(context);
          },
          child: const Text('SAVE'),
        ),
      ],
    ),
  );
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.summary});
  final CartSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Summary', style: AppTextStyles.titleLarge),
          const SizedBox(height: 20),
          _SummaryRow(
            label: 'Subtotal',
            value: '\$${summary.subtotal.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'Shipping',
            value: summary.shippingCost == 0
                ? 'FREE'
                : '\$${summary.shippingCost.toStringAsFixed(2)}',
            valueColor: summary.shippingCost == 0
                ? AppColors.successTeal
                : AppColors.textPrimary,
          ),
          if (summary.discountAmount > 0) ...[
            const SizedBox(height: 12),
            _SummaryRow(
              label: 'Discount',
              value: '-\$${summary.discountAmount.toStringAsFixed(2)}',
              valueColor: AppColors.error,
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: AppColors.borderDefault),
          ),
          _SummaryRow(
            label: 'Total',
            value: '\$${summary.total.toStringAsFixed(2)}',
            isBold: true,
            fontSize: 22,
            valueColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
    this.fontSize = 16,
  });
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
