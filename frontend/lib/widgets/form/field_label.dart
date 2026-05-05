import 'package:flutter/material.dart';

/// A styled label for input fields.
class BuwohFieldLabel extends StatelessWidget {
  final String text;
  const BuwohFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF414944),
        ),
      ),
    );
  }
}
