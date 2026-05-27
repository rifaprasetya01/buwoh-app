import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import '../../theme/theme.dart';

class BuwohReturnFavorCard extends StatelessWidget {
  final String title;
  final String date;
  final String imageUrl;
  final bool isNew;
  final VoidCallback? onTap;

  const BuwohReturnFavorCard({
    super.key,
    required this.title,
    required this.date,
    required this.imageUrl,
    this.isNew = false,
    this.onTap,
  });

  Widget _buildTitle(String text, TextStyle style, double maxWidth) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    if (textPainter.size.width > maxWidth) {
      return SizedBox(
        width: maxWidth,
        height: textPainter.size.height,
        child: Marquee(
          text: text,
          style: style,
          scrollAxis: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          blankSpace: 20.0,
          velocity: 30.0,
          pauseAfterRound: const Duration(seconds: 1),
          accelerationDuration: const Duration(seconds: 1),
          accelerationCurve: Curves.linear,
          decelerationDuration: const Duration(milliseconds: 500),
          decelerationCurve: Curves.easeOut,
        ),
      );
    } else {
      return SizedBox(
        width: maxWidth,
        child: Text(
          text,
          style: style,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(55),
          child: Container(
            width: 110,
            height: 180,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(55),
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(52),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                  opacity: 0.8,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildTitle(
          title,
          const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: AppColors.onSurface,
          ),
          110.0,
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 110,
          child: Text(
            date,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 10,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }
}
