// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars, document_ignores, always_put_required_named_parameters_first, cascade_invocations, avoid_catches_without_on_clauses, use_if_null_to_convert_nulls_to_bools, omit_local_variable_types, directives_ordering, sort_constructors_first, avoid_positional_boolean_parameters

import 'package:dartz/dartz.dart';
import 'package:style_cart/core/errors/failures.dart';

abstract interface class ImageRepository {

  // Upload single image to Firebase Storage
  // Returns download URL
  Future<Either<Failure, String>> uploadProductImage({
    required String localPath,
    required String productId,
    required int index, // 0,1,2... for filename
  });

  // Upload multiple images (returns list of URLs in order)
  Future<Either<Failure, List<String>>> uploadProductImages({
    required List<String> localPaths,
    required String productId,
  });

  // Delete image from Firebase Storage by URL
  Future<Either<Failure, void>> deleteImage(String imageUrl);

  // Delete multiple images
  Future<Either<Failure, void>> deleteImages(
    List<String> imageUrls,
  );

  // Upload user profile photo
  Future<Either<Failure, String>> uploadProfilePhoto({
    required String localPath,
    required String userId,
  });
}

