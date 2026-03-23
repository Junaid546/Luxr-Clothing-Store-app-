// ignore_for_file: public_member_api_docs, document_ignores

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/features/products/domain/repositories/image_repository.dart';

class ImageRepositoryImpl implements ImageRepository {
  final FirebaseStorage _storage;

  const ImageRepositoryImpl(this._storage);

  @override
  Future<Either<Failure, String>> uploadProductImage({
    required String localPath,
    required String productId,
    required int index,
  }) async {
    try {
      final file = File(localPath);
      if (!file.existsSync()) {
        return const Left(
          ValidationFailure('Image file not found'),
        );
      }

      // Validate file size (max 5MB)
      final fileSize = await file.length();
      if (fileSize > 5 * 1024 * 1024) {
        return const Left(
          ValidationFailure('Image must be under 5MB'),
        );
      }

      // Validate file extension
      final ext = localPath.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
        return const Left(
          ValidationFailure('Only JPG, PNG, WEBP allowed'),
        );
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = 'products/$productId/image_${index}_$timestamp.$ext';

      final ref = _storage.ref().child(storagePath);

      // Upload with metadata
      final metadata = SettableMetadata(
        contentType: 'image/$ext',
        customMetadata: {
          'productId': productId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      final uploadTask = ref.putFile(file, metadata);

      // Monitor upload progress (for progress UI)
      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        debugPrint(
          'Upload progress: ${(progress * 100).toInt()}%',
        );
      });

      await uploadTask;
      final downloadUrl = await ref.getDownloadURL();
      return Right(downloadUrl);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(
        'Image upload failed: ${e.message}',
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> uploadProductImages({
    required List<String> localPaths,
    required String productId,
  }) async {
    if (localPaths.isEmpty) {
      return const Left(
        ValidationFailure('No images provided'),
      );
    }
    if (localPaths.length > 8) {
      return const Left(
        ValidationFailure('Maximum 8 images allowed'),
      );
    }

    final urls = <String>[];
    final uploadedPaths = <String>[]; // track for rollback

    for (int i = 0; i < localPaths.length; i++) {
      final result = await uploadProductImage(
        localPath: localPaths[i],
        productId: productId,
        index: i,
      );

      result.fold(
        (failure) async {
          // Rollback: delete already uploaded images
          for (final url in uploadedPaths) {
            await deleteImage(url);
          }
          return Left(failure);
        },
        (url) {
          urls.add(url);
          uploadedPaths.add(url);
        },
      );

      // If we got a failure, stop and return it
      if (result.isLeft()) {
        return Left(result.fold((f) => f, (_) => const ServerFailure()));
      }
    }

    return Right(urls);
  }

  @override
  Future<Either<Failure, void>> deleteImage(
    String imageUrl,
  ) async {
    try {
      // Extract path from URL
      // Firebase Storage URLs contain the path encoded
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return const Right(null);
    } on FirebaseException catch (e) {
      // If file not found — treat as success (idempotent)
      if (e.code == 'object-not-found') {
        return const Right(null);
      }
      return Left(ServerFailure(
        'Failed to delete image: ${e.message}',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteImages(
    List<String> imageUrls,
  ) async {
    // Delete all, collect failures, return first failure
    // Do NOT stop on first failure — delete as many as possible
    final failures = <Failure>[];
    for (final url in imageUrls) {
      final result = await deleteImage(url);
      result.fold(
        (failure) => failures.add(failure),
        (_) {},
      );
    }
    if (failures.isNotEmpty) {
      return Left(failures.first);
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, String>> uploadProfilePhoto({
    required String localPath,
    required String userId,
  }) async {
    try {
      final file = File(localPath);
      final ext = localPath.split('.').last.toLowerCase();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = 'users/$userId/profile_$timestamp.$ext';

      final ref = _storage.ref().child(storagePath);
      await ref.putFile(
          file,
          SettableMetadata(
            contentType: 'image/$ext',
          ));
      return Right(await ref.getDownloadURL());
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Upload failed'));
    }
  }
}
