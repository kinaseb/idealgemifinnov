import 'package:flutter/material.dart';
import 'package:ideal_calcule/class/font_size_provider.dart';
import 'package:ideal_calcule/theme/app_colors.dart';

/// Dialog for adjusting font size
class FontSizeDialog extends StatefulWidget {
  const FontSizeDialog({super.key});

  @override
  State<FontSizeDialog> createState() => _FontSizeDialogState();
}

class _FontSizeDialogState extends State<FontSizeDialog> {
  late double _currentScale;

  @override
  void initState() {
    super.initState();
    _currentScale = fontSizeNotifier.value;
  }

  void _updateScale(double newScale) {
    setState(() {
      _currentScale = newScale;
    });
    fontSizeNotifier.value = newScale;
    FontSizeProvider.saveFontSize(newScale);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentIndex = FontSizeProvider.scales.indexOf(_currentScale);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.darkSurface, AppColors.darkSurface]
                : [AppColors.lightSurface, AppColors.lightSurface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? AppColors.darkPrimaryGradient
                        : AppColors.lightPrimaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.text_fields,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Taille de police',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Preview text
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkCardBorder.withOpacity(0.3)
                      : AppColors.lightCardBorder.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aperçu',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withOpacity(0.6),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ideal Calcule',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 24 * _currentScale,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Calculateur flexo professionnel',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14 * _currentScale,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickButton(
                  context,
                  icon: Icons.remove,
                  label: 'Réduire',
                  onPressed: currentIndex > 0
                      ? () => _updateScale(
                          FontSizeProvider.scales[currentIndex - 1])
                      : null,
                ),
                _buildQuickButton(
                  context,
                  icon: Icons.refresh,
                  label: 'Normal',
                  onPressed: () => _updateScale(FontSizeProvider.normal),
                ),
                _buildQuickButton(
                  context,
                  icon: Icons.add,
                  label: 'Agrandir',
                  onPressed: currentIndex < FontSizeProvider.scales.length - 1
                      ? () => _updateScale(
                          FontSizeProvider.scales[currentIndex + 1])
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  FontSizeProvider.getScaleLabel(_currentScale),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: isDark
                        ? AppColors.darkPrimaryStart
                        : AppColors.lightPrimaryStart,
                    inactiveTrackColor: isDark
                        ? AppColors.darkCardBorder
                        : AppColors.lightCardBorder,
                    thumbColor: isDark
                        ? AppColors.darkPrimaryEnd
                        : AppColors.lightPrimaryEnd,
                    overlayColor: isDark
                        ? AppColors.darkPrimaryStart.withOpacity(0.2)
                        : AppColors.lightPrimaryStart.withOpacity(0.2),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 12,
                    ),
                    trackHeight: 6,
                  ),
                  child: Slider(
                    value: currentIndex.toDouble(),
                    min: 0,
                    max: (FontSizeProvider.scales.length - 1).toDouble(),
                    divisions: FontSizeProvider.scales.length - 1,
                    onChanged: (value) {
                      _updateScale(FontSizeProvider.scales[value.toInt()]);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Scale labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: FontSizeProvider.scaleLabels.map((label) {
                final isSelected =
                    label == FontSizeProvider.getScaleLabel(_currentScale);
                return Text(
                  label.split(' ').first,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? (isDark
                                ? AppColors.darkPrimaryStart
                                : AppColors.lightPrimaryStart)
                            : Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withOpacity(0.5),
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = onPressed != null;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.4,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: isEnabled
                ? (isDark
                    ? AppColors.darkSecondaryGradient
                    : AppColors.lightSecondaryGradient)
                : null,
            color: isEnabled
                ? null
                : (isDark
                    ? AppColors.darkCardBorder
                    : AppColors.lightCardBorder),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: (isDark
                              ? AppColors.darkSecondaryStart
                              : AppColors.lightSecondaryStart)
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontSize: 11,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
