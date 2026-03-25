import 'package:style_cart/features/cart/data/models/cart_item_model.dart';

class CartEntity {
  final List<CartItemModel> items;
  final CartSummary summary;

  const CartEntity({
    required this.items,
    required this.summary,
  });

  bool get isEmpty => items.isEmpty;
}

class CartSummary {
  final double subtotal;
  final double shippingCost;
  final double discountAmount;
  final double totalSavings;
  final double total;
  final bool freeShippingEligible;

  const CartSummary({
    required this.subtotal,
    required this.shippingCost,
    required this.discountAmount,
    required this.totalSavings,
    required this.total,
    required this.freeShippingEligible,
  });

  bool get isEmpty => subtotal == 0;
}
