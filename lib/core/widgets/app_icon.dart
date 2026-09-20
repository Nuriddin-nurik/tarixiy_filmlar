import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders an icon exported from Figma as an SVG asset, tinted to [color].
class AppIcon extends StatelessWidget {
  final String asset;
  final double size;
  final Color color;

  const AppIcon(
    this.asset, {
    super.key,
    this.size = 16,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
