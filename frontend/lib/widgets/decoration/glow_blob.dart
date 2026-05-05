import 'dart:ui';
import 'package:flutter/material.dart';

/// A blurry decorative blob used for background effects.
class BuwohGlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  final double blur;

  const BuwohGlowBlob({
    super.key,
    required this.color,
    this.size = 384,
    this.blur = 80,
  });

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
