// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars, document_ignores, always_put_required_named_parameters_first, cascade_invocations, avoid_catches_without_on_clauses, use_if_null_to_convert_nulls_to_bools, omit_local_variable_types, directives_ordering

import 'package:dartz/dartz.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/features/wishlist/data/models/wishlist_item_model.dart';

abstract interface class WishlistRepository {
  Stream<Either<Failure, List<WishlistItemModel>>> watchWishlist(String userId);
  Future<Either<Failure, void>> addToWishlist(String userId, WishlistItemModel item);
  Future<Either<Failure, void>> removeFromWishlist(String userId, String productId);
  Future<Either<Failure, bool>> isWishlisted(String userId, String productId);
  Future<Either<Failure, void>> clearWishlist(String userId);
}


