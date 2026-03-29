// ignore_for_file: public_member_api_docs, document_ignores

import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/features/products/domain/repositories/image_repository.dart';

class ImageRepositoryImpl implements ImageRepository {
  const ImageRepositoryImpl(this._storage);
  final FirebaseStorage _storage;

  @override
  Future<Either<Failure, String>> uploadProductImage({
    required String localPath,
    required String productId,
    required int index,
  }) async {
    Reference? ref;
    String? storagePath;

    try {
      final file = File(localPath);
      if (!file.existsSync()) {
        return const Left(ValidationFailure('Image file not found'));
      }

      // Validate file size (max 5MB)
      final fileSize = await file.length();
      if (fileSize > 5 * 1024 * 1024) {
        return const Left(ValidationFailure('Image must be under 5MB'));
      }

      // Validate file extension
      final ext = localPath.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
        return const Left(ValidationFailure('Only JPG, PNG, WEBP allowed'));
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      storagePath = 'products/$productId/image_${index}_$timestamp.$ext';

      ref = _storage.ref().child(storagePath);

      // Upload with metadata
      final metadata = SettableMetadata(
        contentType: _contentTypeForExtension(ext),
        customMetadata: {
          'productId': productId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      debugPrint('Uploading product image to ${ref.bucket}/${ref.fullPath}');

      final uploadTask = ref.putFile(file, metadata);

      // Monitor upload progress (for progress UI)
      uploadTask.snapshotEvents.listen(
        (snapshot) {
          if (snapshot.totalBytes > 0) {
            final progress = snapshot.bytesTransferred / snapshot.totalBytes;
            debugPrint('Upload progress: ${(progress * 100).toInt()}%');
          }
        },
        onError: (Object e) {
          debugPrint('Stream Error in uploadProductImage: $e');
        },
        cancelOnError: true,
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return Right(downloadUrl);
    } on FirebaseException catch (e) {
      _logStorageFailure(
        action: 'upload',
        reference: ref,
        storagePath: storagePath,
        error: e,
      );
      return Left(_mapStorageFailure(e));
    } on Object catch (e) {
      debugPrint(
        'Unexpected product image upload error at '
        '${storagePath ?? localPath}: $e',
      );
      return const Left(
        ServerFailure('Image upload failed. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, List<String>>> uploadProductImages({
    required List<String> localPaths,
    required String productId,
  }) async {
    if (localPaths.isEmpty) {
      return const Left(ValidationFailure('No images provided'));
    }
    if (localPaths.length > 8) {
      return const Left(ValidationFailure('Maximum 8 images allowed'));
    }

    final urls = <String>[];
    final uploadedPaths = <String>[]; // track for rollback

    try {
      for (var i = 0; i < localPaths.length; i++) {
        final result = await uploadProductImage(
          localPath: localPaths[i],
          productId: productId,
          index: i,
        );

        final failureOrUrl = result.fold(Left<Failure, String>.new, (url) {
          urls.add(url);
          uploadedPaths.add(url);
          return Right<Failure, String>(url);
        });

        if (failureOrUrl.isLeft()) {
          // Rollback: delete already uploaded images
          for (final url in uploadedPaths) {
            unawaited(
              deleteImage(
                url,
              ).catchError((_) => const Right<Failure, void>(null)),
            );
          }
          return Left(
            failureOrUrl.fold((f) => f, (_) => const ServerFailure()),
          );
        }
      }
      return Right(urls);
    } on Object catch (e) {
      return Left(ServerFailure('Multi-upload failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteImage(String imageUrl) async {
    if (!_isFirebaseStorageUrl(imageUrl)) {
      return const Right(null);
    }

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
      _logStorageFailure(
        action: 'delete',
        reference: null,
        storagePath: imageUrl,
        error: e,
      );
      return Left(
        _mapStorageFailure(
          e,
          fallbackMessage: 'Failed to delete image. Please try again.',
        ),
      );
    } on Object {
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, void>> deleteImages(List<String> imageUrls) async {
    // Delete all, collect failures, return first failure
    // Do NOT stop on first failure — delete as many as possible
    final failures = <Failure>[];
    for (final url in imageUrls) {
      final result = await deleteImage(url);
      result.fold(failures.add, (_) {});
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
      await ref.putData(
        await file.readAsBytes(),
        SettableMetadata(contentType: 'image/$ext'),
      );
      return Right(await ref.getDownloadURL());
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Upload failed'));
    }
  }

  String _contentTypeForExtension(String ext) {
    return switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'application/octet-stream',
    };
  }

  bool _isFirebaseStorageUrl(String imageUrl) {
    if (imageUrl.startsWith('gs://')) {
      return true;
    }

    final uri = Uri.tryParse(imageUrl);
    if (uri == null) {
      return false;
    }

    final host = uri.host.toLowerCase();
    return host.contains('firebasestorage.googleapis.com') ||
        host.contains('storage.googleapis.com');
  }

  Failure _mapStorageFailure(
    FirebaseException error, {
    String? fallbackMessage,
  }) {
    return switch (error.code) {
      'object-not-found' => const NotFoundFailure(
        'Firebase Storage is not available for this project. '
        'Use a public image URL instead of device upload.',
      ),
      'unauthorized' => const PermissionFailure(
        'You do not have permission to upload product images. '
        'Please sign in with an admin account.',
      ),
      'bucket-not-found' => const ServerFailure(
        'Firebase Storage is not enabled for this project. '
        'Use a public image URL instead of device upload.',
      ),
      'no-default-bucket' => const ServerFailure(
        'Firebase Storage is not enabled for this project. '
        'Use a public image URL instead of device upload.',
      ),
      'quota-exceeded' => const ServerFailure(
        'Firebase Storage quota exceeded. Please try again later.',
      ),
      'canceled' => const ServerFailure(
        'Image upload was canceled before completion.',
      ),
      'invalid-checksum' => const ServerFailure(
        'Image upload failed integrity checks. Please try again.',
      ),
      _ => ServerFailure(
        fallbackMessage ??
            error.message ??
            'Image upload failed. Please try again.',
      ),
    };
  }

  void _logStorageFailure({
    required String action,
    required Reference? reference,
    required String? storagePath,
    required FirebaseException error,
  }) {
    debugPrint(
      'Firebase Storage $action failed '
      '[bucket=${reference?.bucket ?? _storage.app.options.storageBucket}, '
      'path=${reference?.fullPath ?? storagePath ?? 'unknown'}, '
      'code=${error.code}]: ${error.message}',
    );
  }
}
