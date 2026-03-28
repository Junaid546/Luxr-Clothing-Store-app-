import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stylecart/core/constants/firestore_schema.dart';
import 'package:stylecart/features/cart/data/models/cart_item_model.dart';

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
  final int totalItems;
  final bool freeShippingEligible;

  const CartSummary({
    required this.subtotal,
    required this.shippingCost,
    required this.discountAmount,
    required this.totalSavings,
    required this.total,
    required this.totalItems,
    required this.freeShippingEligible,
  });

  bool get isEmpty => subtotal == 0;

  factory CartSummary.compute({
    required List<CartItemModel> items,
    String shippingMethod = ShippingMethod.standard,
    double discountAmount = 0,
  }) {
    final thresholdString = dotenv.env['FREE_SHIPPING_THRESHOLD'] ?? '100';
    final threshold = double.tryParse(thresholdString) ?? 100.0;

    final subtotal = items.fold(0.0, (sum, i) => sum + i.lineTotal);
    final totalItems = items.fold(0, (sum, i) => sum + i.quantity);
    final isFreeShipping = subtotal >= threshold;

    double shippingCost = 0.0;
    if (shippingMethod == ShippingMethod.express) {
      final expressCostString = dotenv.env['EXPRESS_SHIPPING_COST'] ?? '25';
      shippingCost = double.tryParse(expressCostString) ?? 25.0;
    } else if (!isFreeShipping && items.isNotEmpty) {
      shippingCost = 0.0; // Standard is free in our app
    }

    // Savings from product discounts
    final totalSavings = items.fold(
      0.0,
      (sum, i) => sum + ((i.unitPrice - i.finalPrice) * i.quantity),
    );

    return CartSummary(
      subtotal: subtotal,
      shippingCost: shippingCost,
      discountAmount: discountAmount,
      totalSavings: totalSavings,
      total: subtotal + shippingCost - discountAmount,
      totalItems: totalItems,
      freeShippingEligible: isFreeShipping,
    );
  }
}

class CartValidationResult {
  final List<CartItemModel> validatedItems;
  final List<StockIssue> stockIssues;
  final List<PriceChange> priceChanges;

  const CartValidationResult({
    required this.validatedItems,
    required this.stockIssues,
    required this.priceChanges,
  });

  bool get isValid => stockIssues.isEmpty;
  bool get hasPriceChanges => priceChanges.isNotEmpty;
}

class StockIssue {
  final String productId;
  final String productName;
  final String size;
  final int requested;
  final int available;
  final String reason;

  const StockIssue({
    required this.productId,
    required this.productName,
    required this.size,
    required this.requested,
    required this.available,
    required this.reason,
  });
}

class PriceChange {
  final String productId;
  final String productName;
  final double oldPrice;
  final double newPrice;

  const PriceChange({
    required this.productId,
    required this.productName,
    required this.oldPrice,
    required this.newPrice,
  });

  bool get isIncrease => newPrice > oldPrice;
}
