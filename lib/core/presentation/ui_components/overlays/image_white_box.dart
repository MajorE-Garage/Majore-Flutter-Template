import 'package:flutter/material.dart';

import '../../../../core/presentation/theming/app_colors.dart';
import '../others/cached_picture_widget.dart';
import 'app_bottom_sheet.dart';

class ImageWhiteBox extends AppBottomSheet<void> {
  ImageWhiteBox({
    super.key,
    required super.heading,
    required String? imageUrl,
  }) : super(
          builder: (context) => Column(
            children: [
              const Divider(height: 1),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                  color: AppColors.of(context).overlayBackground,
                ),
                alignment: Alignment.center,
                child: InteractiveViewer(
                  minScale: 0.6,
                  maxScale: 4,
                  child: AppCachedImage(
                    imageUrl: imageUrl,
                  ),
                ),
              ),
            ],
          ),
        );
}
