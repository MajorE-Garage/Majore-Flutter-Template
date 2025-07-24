import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/presentation/presentation.dart';

/// This widget renders a rectangle shaped element and animates a gradient
/// across its dimensions to give a shimmering effect.
/// To be used for loading states for mainly lists and grids.
class AppShimmer extends StatelessWidget {
  /// Creates a shimmer with borders on all sides.
  const AppShimmer({
    super.key,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.constraints = const BoxConstraints(minHeight: 40),
    this.height,
    this.width,
    this.flip = false,
    required this.child,
  }) : _borderless = false;

  /// Creates a shimmer without any borders.
  const AppShimmer.borderless({
    super.key,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.constraints = const BoxConstraints(minHeight: 40),
    this.height,
    this.width,
    this.flip = false,
    required this.child,
  }) : _borderless = true;

  final Widget child;

  /// Sets the border radius of the shimmer's rectangle.
  /// Defaults to a circular radius of 12 for all sides.
  final BorderRadius? borderRadius;

  /// Sets the constraints of the shimmer's rectangle.
  /// This is a convenient way to create a shimmer that adjusts its size
  /// depending on its parent and the constraints provided.
  /// Ensure height and width properties are null to use constraints.
  /// Defaults to BoxConstraints(minHeight: 40)
  final BoxConstraints? constraints;

  /// Sets the height of the shimmer's rectangle. If either height or width
  /// is provided, the constraints property is ignored.
  final double? height;

  /// Sets the width of the shimmer's rectangle. If either width or height
  /// is provided, the constraints property is ignored.
  final double? width;

  /// Decides the direction the shimmer animates its gradient in.
  /// When true, shimmer animates from right to left, and opposite when false.
  /// Default is false.
  final bool flip;
  final bool _borderless;

  @override
  Widget build(BuildContext context) {
    // var effectiveConstraints = constraints;

    // if (height != null || width != null) {
    //   effectiveConstraints = BoxConstraints.tightFor(
    //     height: height,
    //     width: width,
    //   );
    // }
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: _borderless
            ? null
            : Border.fromBorderSide(
                BorderSide(color: AppColors.of(context).grey800),
              ),
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.of(context).grey500.withAlpha(26),
        highlightColor: AppColors.of(context).grey600.withAlpha(128),
        direction: !flip ? ShimmerDirection.ltr : ShimmerDirection.rtl,
        child: child,
      ),
    );
  }
}
