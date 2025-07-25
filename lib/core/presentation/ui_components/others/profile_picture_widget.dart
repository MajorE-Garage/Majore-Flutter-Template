import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';

import '../../presentation.dart';

class ProfilePictureWidget extends StatelessWidget {
  const ProfilePictureWidget({super.key, this.image, this.size = 48, this.borderWidth});

  ProfilePictureWidget.network({super.key, String? imageUrl, this.size = 48, this.borderWidth})
    : image = imageUrl == null ? null : CachedNetworkImageProvider(imageUrl);

  final double size;
  final ImageProvider? image;
  final double? borderWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.grey300,
        border: borderWidth == null
            ? null
            : Border.all(
                color: AppColors.of(context).primaryColor.withAlpha(51),
                width: borderWidth!,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
      ),
      clipBehavior: Clip.antiAlias,
      child: image != null
          ? Image(
              image: image!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                Logger(runtimeType.toString()).severe('Failed to render profile image', error, stackTrace);
                return Align(
                  alignment: Alignment.center,
                  child: Icon(
                    CupertinoIcons.person_2_alt,
                    size: size * 0.6,
                    color: context.colors.primaryColor.withAlpha(51),
                  ),
                );
              },
            )
          : Align(
              alignment: Alignment.center,
              child: Icon(
                CupertinoIcons.person_2_alt,
                size: size * 0.6,
                color: context.colors.primaryColor.withAlpha(51),
              ),
            ),
    );
  }
}
