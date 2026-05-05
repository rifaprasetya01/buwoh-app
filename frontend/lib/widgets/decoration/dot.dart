import 'package:flutter/material.dart';

/// A simple colored dot used for indicators or decoration.
class BuwohDot extends StatelessWidget {
  final Color color;
  final double size;

  const BuwohDot({
    super.key,
    required this.color,
    this.size = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
