// ignore_for_file: public_member_api_docs, sort_constructors_first, always_put_required_named_parameters_first, invalid_annotation_target, sort_unnamed_constructors_first, lines_longer_than_80_chars, document_ignores
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'wishlist_item_model.freezed.dart';

@freezed
class WishlistItemModel with _$WishlistItemModel {
  const WishlistItemModel._();

  const factory WishlistItemModel({
    required String productId,
    required String productName,
    required String brand,
    required String imageUrl,
    required double price,
    required int discountPct,
    required double finalPrice,
    required String category,
    required bool isLimitedEdition,
    required DateTime addedAt,
  }) = _WishlistItemModel;

  factory WishlistItemModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? const <String, dynamic>{};
    return WishlistItemModel(
      productId:   doc.id,
      productName: d['productName'] as String? ?? '',
      brand:       d['brand']       as String? ?? '',
      imageUrl:    d['imageUrl']    as String? ?? '',
      price:       (d['price']      as num?)?.toDouble() ?? 0.0,
      discountPct: (d['discountPct'] as num?)?.toInt() ?? 0,
      finalPrice:  (d['finalPrice']  as num?)?.toDouble() ?? 0.0,
      category:    d['category']    as String? ?? '',
      isLimitedEdition: d['isLimitedEdition'] as bool? ?? false,
      addedAt:     (d['addedAt']    as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'productId':   productId,
    'productName': productName,
    'brand':       brand,
    'imageUrl':    imageUrl,
    'price':       price,
    'discountPct': discountPct,
    'finalPrice':  finalPrice,
    'category':    category,
    'isLimitedEdition': isLimitedEdition,
    'addedAt':     FieldValue.serverTimestamp(),
  };
}



