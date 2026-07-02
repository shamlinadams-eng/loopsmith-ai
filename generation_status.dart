import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class GenerationStatus extends StatelessWidget {
  final int remaining;

  const GenerationStatus({super.key, required this.remaining});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;
    final text = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('LoopSmith AI', style: text.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            )),
            const SizedBox(height: AppTheme.spacingXs),
            Text(
              'AI-powered loop generation',
              style: text.bodySmall?.copyWith(color: appColors.subtleText),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingSm,
            vertical: AppTheme.spacingXs,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusRound),
            color: remaining > 3
                ? appColors.neonAccent.withOpacity(AppTheme.opacityGlass)
                : appColors.warning.withOpacity(AppTheme.opacityGlass),
            border: Border.all(
              color: remaining > 3
                  ? appColors.neonAccent.withOpacity(AppTheme.opacityGlassBorder)
                  : appColors.warning.withOpacity(AppTheme.opacityGlassBorder),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bolt,
                size: AppTheme.iconSm,
                color: remaining > 3 ? appColors.neonAccent : appColors.warning,
              ),
              const SizedBox(width: AppTheme.spacingXs),
              Text(
                '$remaining left',
                style: text.labelSmall?.copyWith(
                  color: remaining > 3 ? appColors.neonAccent : appColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
