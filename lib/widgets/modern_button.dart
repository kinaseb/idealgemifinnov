import 'package:flutter/material.dart';
import 'package:ideal_calcule/theme/app_colors.dart';

/// Modern gradient button
class ModernButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isSecondary;
  final bool isSmall;

  const ModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isSecondary = false,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = isSecondary
        ? (isDark
            ? AppColors.darkSecondaryGradient
            : AppColors.lightSecondaryGradient)
        : (isDark
            ? AppColors.darkPrimaryGradient
            : AppColors.lightPrimaryGradient);

    return Container(
      decoration: BoxDecoration(
        gradient: onPressed != null ? gradient : null,
        color: onPressed == null
            ? (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder)
            : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: (isSecondary
                          ? (isDark
                              ? AppColors.darkSecondaryStart
                              : AppColors.lightSecondaryStart)
                          : (isDark
                              ? AppColors.darkPrimaryStart
                              : AppColors.lightPrimaryStart))
                      .withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 16 : 24,
              vertical: isSmall ? 12 : 16,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: Colors.white,
                    size: isSmall ? 18 : 20,
                  ),
                  SizedBox(width: isSmall ? 6 : 8),
                ],
                Text(
                  text,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
