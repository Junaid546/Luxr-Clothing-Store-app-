import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:style_cart/core/constants/firestore_schema.dart';
import 'package:style_cart/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:style_cart/features/cart/domain/entities/cart_entity.dart';
import 'package:style_cart/features/cart/domain/usecases/validate_cart_use_case.dart';
import 'package:style_cart/features/cart/presentation/providers/cart_notifier.dart';
import 'package:style_cart/features/orders/data/models/order_model.dart';
import 'package:style_cart/features/orders/data/services/order_placement_service.dart';

part 'checkout_notifier.g.dart';

enum CheckoutStep { address, shipping, payment }

class CheckoutState {

  const CheckoutState({
    this.step = CheckoutStep.address,
    this.selectedAddress,
    this.shippingMethod = ShippingMethod.standard,
    this.paymentMethod = PaymentMethod.cod,
    this.validatedCart,
    this.isProcessing = false,
    this.error,
    this.successOrderId,
  });
  final CheckoutStep step;
  final ShippingAddressModel? selectedAddress;
  final String shippingMethod;
  final String paymentMethod;
  final CartValidationResult? validatedCart;
  final bool isProcessing;
  final String? error;
  final String? successOrderId;

  CheckoutState copyWith({
    CheckoutStep? step,
    ShippingAddressModel? selectedAddress,
    String? shippingMethod,
    String? paymentMethod,
    CartValidationResult? validatedCart,
    bool? isProcessing,
    String? error,
    String? successOrderId,
  }) {
    return CheckoutState(
      step: step ?? this.step,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      shippingMethod: shippingMethod ?? this.shippingMethod,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      validatedCart: validatedCart ?? this.validatedCart,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error, // Can be null to clear
      successOrderId: successOrderId ?? this.successOrderId,
    );
  }
}

@riverpod
class CheckoutNotifier extends _$CheckoutNotifier {
  @override
  CheckoutState build() {
    return const CheckoutState();
  }

  // ── Step Navigation ──────────────────────────────
  void nextStep() => state = state.copyWith(step: CheckoutStep.values[state.step.index + 1]);
  void prevStep() => state = state.copyWith(step: CheckoutStep.values[state.step.index - 1]);
  void setStep(CheckoutStep step) => state = state.copyWith(step: step);

  // ── Selections ───────────────────────────────────
  void setAddress(ShippingAddressModel address) => state = state.copyWith(selectedAddress: address);
  void setShippingMethod(String method) => state = state.copyWith(shippingMethod: method);
  void setPaymentMethod(String method) => state = state.copyWith(paymentMethod: method);

  // ── VALIDATE ALL ────────────────────────────────
  Future<bool> validateCheckout() async {
    state = state.copyWith(isProcessing: true);

    final cartItems = ref.read(cartItemsProvider).value ?? [];
    final authState = ref.read(authNotifierProvider);
    
    if (authState is! AuthAuthenticated) {
      state = state.copyWith(isProcessing: false, error: 'User not authenticated');
      return false;
    }
    final user = authState.user;

    final result = await ref.read(validateCartUseCaseProvider.notifier).call(
      ValidateCartParams(userId: user.uid, cartItems: cartItems),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isProcessing: false, error: failure.message);
        return false;
      },
      (validated) {
        if (!validated.isValid) {
          final issue = validated.stockIssues.first;
          state = state.copyWith(isProcessing: false, error: issue.reason);
          return false;
        }
        state = state.copyWith(isProcessing: false, validatedCart: validated);
        return true;
      },
    );
  }

  // ── PLACE ORDER ──────────────────────────────────
  Future<void> placeOrder() async {
    if (state.selectedAddress == null || state.validatedCart == null) return;

    state = state.copyWith(isProcessing: true);

    final authState = ref.read(authNotifierProvider);
    if (authState is! AuthAuthenticated) {
      state = state.copyWith(isProcessing: false, error: 'User not authenticated');
      return;
    }
    final user = authState.user;

    final result = await ref.read(orderPlacementServiceProvider).placeOrder(
      validatedCart: state.validatedCart!,
      user: user,
      shippingAddress: state.selectedAddress!,
      shippingMethod: state.shippingMethod,
      paymentMethod: state.paymentMethod,
      discountAmount: 0, // Future: Add coupon support
    );

    result.fold(
      (failure) => state = state.copyWith(isProcessing: false, error: failure.message),
      (orderId) => state = state.copyWith(isProcessing: false, successOrderId: orderId),
    );
  }
}
