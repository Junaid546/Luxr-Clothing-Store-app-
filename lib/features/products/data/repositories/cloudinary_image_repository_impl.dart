// ignore_for_file: public_member_api_docs, document_ignores

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/features/products/domain/repositories/image_repository.dart';

class CloudinaryImageRepositoryImpl implements ImageRepository {
  CloudinaryImageRepositoryImpl({
    required String cloudName,
    required String uploadPreset,
    String? pathPrefix,
  }) : _cloudName = cloudName.trim(),
       _uploadPreset = uploadPreset.trim(),
       _pathPrefix = pathPrefix?.trim() ?? '';

  final String _cloudName;
  final String _uploadPreset;
  final String _pathPrefix;

  Uri get _uploadUri =>
      Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');

  @override
  Future<Either<Failure, String>> uploadProductImage({
    required String localPath,
    required String productId,
    required int index,
  }) async {
    final fileValidation = await _validateImageFile(localPath);
    if (fileValidation != null) {
      return Left(fileValidation);
    }

    final configFailure = _validateConfiguration();
    if (configFailure != null) {
      return Left(configFailure);
    }

    final ext = localPath.split('.').last.toLowerCase();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final publicId = _buildPublicId(
      'products/$productId/image_${index}_$timestamp',
    );

    return _uploadImageFile(
      localPath: localPath,
      fileExtension: ext,
      publicId: publicId,
      context: {'productId': productId},
      tags: ['product', productId],
    );
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

    for (var i = 0; i < localPaths.length; i++) {
      final result = await uploadProductImage(
        localPath: localPaths[i],
        productId: productId,
        index: i,
      );

      Failure? uploadFailure;
      result.fold((failure) => uploadFailure = failure, urls.add);

      if (uploadFailure != null) {
        return Left(uploadFailure!);
      }
    }

    return Right(urls);
  }

  @override
  Future<Either<Failure, void>> deleteImage(String imageUrl) async {
    debugPrint(
      'Skipping remote delete for $imageUrl because Cloudinary '
      'asset deletion should be handled server-side.',
    );
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteImages(List<String> imageUrls) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, String>> uploadProfilePhoto({
    required String localPath,
    required String userId,
  }) async {
    final fileValidation = await _validateImageFile(localPath);
    if (fileValidation != null) {
      return Left(fileValidation);
    }

    final configFailure = _validateConfiguration();
    if (configFailure != null) {
      return Left(configFailure);
    }

    final ext = localPath.split('.').last.toLowerCase();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final publicId = _buildPublicId('users/$userId/profile_$timestamp');

    return _uploadImageFile(
      localPath: localPath,
      fileExtension: ext,
      publicId: publicId,
      context: {'userId': userId},
      tags: ['profile', userId],
    );
  }

  Future<Either<Failure, String>> _uploadImageFile({
    required String localPath,
    required String fileExtension,
    required String publicId,
    required Map<String, String> context,
    required List<String> tags,
  }) async {
    try {
      final request = http.MultipartRequest('POST', _uploadUri)
        ..fields['upload_preset'] = _uploadPreset
        ..fields['public_id'] = publicId
        ..fields['tags'] = tags.join(',')
        ..fields['context'] = _encodeContext(context)
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            localPath,
            filename: 'upload.$fileExtension',
          ),
        );

      debugPrint(
        'Uploading image to Cloudinary '
        '[url=$_uploadUri, publicId=$publicId]',
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 45),
      );
      final response = await http.Response.fromStream(streamedResponse);
      final payload = _decodeJson(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return Left(_mapUploadFailure(response.statusCode, payload));
      }

      final secureUrl = payload?['secure_url'] as String?;
      if (secureUrl == null || secureUrl.isEmpty) {
        return const Left(
          ServerFailure(
            'Cloudinary upload succeeded but no image URL was returned.',
          ),
        );
      }

      return Right(secureUrl);
    } on TimeoutException {
      return const Left(
        ServerFailure('Cloudinary upload timed out. Please try again.'),
      );
    } on SocketException {
      return const Left(
        ServerFailure(
          'Could not reach Cloudinary. Check your internet connection.',
        ),
      );
    } on Object catch (error) {
      debugPrint('Unexpected Cloudinary upload error: $error');
      return const Left(
        ServerFailure('Cloudinary upload failed. Please try again.'),
      );
    }
  }

  Future<Failure?> _validateImageFile(String localPath) async {
    final file = File(localPath);
    if (!file.existsSync()) {
      return const ValidationFailure('Image file not found');
    }

    final fileSize = await file.length();
    if (fileSize > 5 * 1024 * 1024) {
      return const ValidationFailure('Image must be under 5MB');
    }

    final ext = localPath.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
      return const ValidationFailure('Only JPG, PNG, WEBP allowed');
    }

    return null;
  }

  Failure? _validateConfiguration() {
    if (_isPlaceholderValue(_cloudName) || _isPlaceholderValue(_uploadPreset)) {
      return const ServerFailure(
        'Cloudinary is not configured. Add CLOUDINARY_CLOUD_NAME and '
        'CLOUDINARY_UPLOAD_PRESET to your local .env file.',
      );
    }

    return null;
  }

  bool _isPlaceholderValue(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ||
        trimmed.toUpperCase().startsWith('YOUR_') ||
        trimmed.toLowerCase().contains('unsigned_preset');
  }

  String _buildPublicId(String basePath) {
    if (_pathPrefix.isEmpty || _isPlaceholderValue(_pathPrefix)) {
      return basePath;
    }

    if (basePath == _pathPrefix || basePath.startsWith('$_pathPrefix/')) {
      return basePath;
    }

    return '$_pathPrefix/$basePath';
  }

  String _encodeContext(Map<String, String> context) {
    return context.entries
        .where((entry) => entry.value.trim().isNotEmpty)
        .map((entry) => '${entry.key}=${entry.value}')
        .join('|');
  }

  Map<String, dynamic>? _decodeJson(String body) {
    if (body.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  Failure _mapUploadFailure(int statusCode, Map<String, dynamic>? payload) {
    final message =
        (payload?['error'] as Map<String, dynamic>?)?['message'] as String?;

    return switch (statusCode) {
      400 => ValidationFailure(
        message ??
            'Cloudinary rejected the upload request. Check your upload preset.',
      ),
      401 || 403 => PermissionFailure(
        message ??
            'Cloudinary upload is not authorized. '
                'Use an unsigned upload preset.',
      ),
      404 => const ServerFailure(
        'Cloudinary cloud name is incorrect or not configured.',
      ),
      _ => ServerFailure(
        message ?? 'Cloudinary upload failed. Please try again.',
      ),
    };
  }
}
