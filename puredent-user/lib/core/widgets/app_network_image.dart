import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_colors.dart';

/// Standard lazy-loaded, memory-cached network image used everywhere in the
/// app (doctor avatars, service thumbnails, etc). Centralizing this means
/// every image benefits from disk+memory caching and a consistent shimmer
/// placeholder without each screen re-implementing it.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 200),
      // Decode at roughly the display size to avoid holding full-resolution
      // bitmaps in memory for thumbnails.
      memCacheWidth: width != null ? (width! * 2).round() : null,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: AppColors.surfaceContainerHigh,
        highlightColor: AppColors.surfaceContainerLowest,
        child: Container(color: AppColors.surfaceContainerHigh, width: width, height: height),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: AppColors.surfaceContainerHigh,
        child: const Icon(Icons.image_not_supported_outlined, color: AppColors.outline),
      ),
    );

    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}
