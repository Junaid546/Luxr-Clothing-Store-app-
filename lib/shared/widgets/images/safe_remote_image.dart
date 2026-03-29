import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:style_cart/app/theme/app_colors.dart';

class SafeRemoteImage extends StatelessWidget {
  const SafeRemoteImage({
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    super.key,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  static final Map<String, Future<Uint8List?>> _memoryCache =
      <String, Future<Uint8List?>>{};

  @override
  Widget build(BuildContext context) {
    if (imageUrl.trim().isEmpty) {
      return _wrap(_buildError());
    }

    return _wrap(
      FutureBuilder<Uint8List?>(
        future: _memoryCache.putIfAbsent(
          imageUrl,
          () => _downloadAndNormalizeImage(imageUrl),
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return _buildPlaceholder();
          }

          final bytes = snapshot.data;
          if (bytes == null || bytes.isEmpty) {
            return _buildError();
          }

          return Image.memory(
            bytes,
            width: width,
            height: height,
            fit: fit,
            alignment: alignment,
            gaplessPlayback: true,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, __, ___) => _buildError(),
          );
        },
      ),
    );
  }

  Widget _wrap(Widget child) {
    if (borderRadius == null) {
      return child;
    }

    return ClipRRect(borderRadius: borderRadius!, child: child);
  }

  Widget _buildPlaceholder() {
    return placeholder ??
        Container(
          width: width,
          height: height,
          color: AppColors.backgroundCard,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
  }

  Widget _buildError() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          color: AppColors.backgroundCard,
          alignment: Alignment.center,
          child: const Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.textMuted,
          ),
        );
  }

  static Future<Uint8List?> _downloadAndNormalizeImage(String imageUrl) async {
    final uri = Uri.tryParse(imageUrl);
    if (uri == null) {
      return null;
    }

    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);

    try {
      final request = await client.getUrl(uri);
      request.followRedirects = true;
      request.maxRedirects = 5;
      request.headers.set(HttpHeaders.acceptHeader, 'image/*');

      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final bytes = await consolidateHttpClientResponseBytes(response);
      if (bytes.isEmpty) {
        return null;
      }

      final decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) {
        debugPrint('SafeRemoteImage could not decode $imageUrl');
        return null;
      }

      final normalizedImage = _resizeIfNeeded(decodedImage);
      if (normalizedImage.hasAlpha) {
        return Uint8List.fromList(img.encodePng(normalizedImage));
      }

      return Uint8List.fromList(img.encodeJpg(normalizedImage, quality: 85));
    } on Object catch (error) {
      debugPrint('SafeRemoteImage failed for $imageUrl: $error');
      return null;
    } finally {
      client.close(force: true);
    }
  }

  static img.Image _resizeIfNeeded(img.Image source) {
    final longestSide = source.width > source.height
        ? source.width
        : source.height;

    if (longestSide <= 1600) {
      return source;
    }

    if (source.width >= source.height) {
      return img.copyResize(source, width: 1600);
    }

    return img.copyResize(source, height: 1600);
  }
}
