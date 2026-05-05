import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class BuwohActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isHighlighted;
  final bool showArrow;
  final VoidCallback onTap;

  const BuwohActionItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isHighlighted,
    required this.showArrow,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isHighlighted ? AppColors.primaryContainer : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isHighlighted
              ? [
                  BoxShadow(
                    color: AppColors.primaryContainer.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isHighlighted
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.white,
                boxShadow: isHighlighted
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 4,
                        ),
                      ],
              ),
              child: Icon(
                icon,
                color: isHighlighted ? Colors.white : AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 15,
                  fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w600,
                  color: isHighlighted ? Colors.white : AppColors.onSurface,
                ),
              ),
            ),
            if (showArrow)
              Icon(
                Icons.chevron_right,
                color: isHighlighted ? Colors.white : AppColors.onSurfaceVariant,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
