import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart_item_model.freezed.dart';

@freezed
class CartItemModel with _$CartItemModel {
  const CartItemModel._();

  const factory CartItemModel({
    required String cartItemId,
    required String productId,
    required String productName,
    required String brand,
    required String imageUrl,
    required String size,
    required String color,
    required String colorHex,
    required int quantity,
    required double unitPrice,
    required int discountPct,
    required double finalPrice,
    required DateTime addedAt,
    required DateTime updatedAt,
  }) = _CartItemModel;

  double get lineTotal => finalPrice * quantity;

  // Document ID generation: productId_size_colorNoSpaces
  static String generateId(
    String productId, String size, String color,
  ) => '${productId}_${size}_${color.replaceAll(' ', '')}';

  factory CartItemModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CartItemModel(
      cartItemId:  doc.id,
      productId:   d['productId']   as String? ?? '',
      productName: d['productName'] as String? ?? '',
      brand:       d['brand']       as String? ?? '',
      imageUrl:    d['imageUrl']    as String? ?? '',
      size:        d['size']        as String? ?? '',
      color:       d['color']       as String? ?? '',
      colorHex:    d['colorHex']    as String? ?? '#000000',
      quantity:    (d['quantity']   as num?)?.toInt() ?? 1,
      unitPrice:   (d['unitPrice']  as num?)?.toDouble() ?? 0,
      discountPct: (d['discountPct'] as num?)?.toInt() ?? 0,
      finalPrice:  (d['finalPrice'] as num?)?.toDouble() ?? 0,
      addedAt:     (d['addedAt']    as Timestamp?)?.toDate()
                     ?? DateTime.now(),
      updatedAt:   (d['updatedAt']  as Timestamp?)?.toDate()
                     ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'cartItemId':  cartItemId,
    'productId':   productId,
    'productName': productName,
    'brand':       brand,
    'imageUrl':    imageUrl,
    'size':        size,
    'color':       color,
    'colorHex':    colorHex,
    'quantity':    quantity,
    'unitPrice':   unitPrice,
    'discountPct': discountPct,
    'finalPrice':  finalPrice,
    'addedAt':     FieldValue.serverTimestamp(),
    'updatedAt':   FieldValue.serverTimestamp(),
  };
}
