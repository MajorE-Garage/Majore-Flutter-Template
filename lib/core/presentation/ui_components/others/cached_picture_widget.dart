import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../presentation.dart';

class AppCachedImage extends StatelessWidget {
  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius = const BorderRadius.all(Radius.circular(10.0)),
    this.color = Colors.transparent,
    this.placeholder,
  });

  final String? imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final Color color;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return Container(
        height: height,
        width: width,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(borderRadius: borderRadius, color: color),
        alignment: Alignment.center,
        child: placeholder ?? Icon(Icons.image_rounded, color: AppColors.of(context).grey700),
      );
    }
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(borderRadius: borderRadius, color: color),
      child: CachedNetworkImage(
        height: height,
        width: width,
        fit: fit,
        imageUrl: imageUrl!,
        fadeOutDuration: const Duration(milliseconds: 500),
        fadeInDuration: const Duration(milliseconds: 500),
        placeholder: (_, __) => Container(
          color: color,
          alignment: Alignment.center,
          child: placeholder ?? Icon(Icons.image, color: AppColors.of(context).primaryColor),
        ),
        errorWidget: (_, __, ___) => Container(
          color: color,
          alignment: Alignment.center,
          child: placeholder ?? Icon(Icons.image, color: AppColors.of(context).grey700),
        ),
      ),
    );
  }
}
