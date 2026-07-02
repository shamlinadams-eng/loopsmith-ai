import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class PlaceholderScreen extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const PlaceholderScreen({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: appColors.neonAccent.withOpacity(AppTheme.opacityGlass),
                  border: Border.all(color: appColors.glassBorder),
                ),
                child: Icon(icon, size: AppTheme.iconLg, color: appColors.neonAccent),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              Text('Coming Soon', style: text.headlineSmall),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                subtitle,
                style: text.bodyMedium?.copyWith(color: appColors.subtleText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingLg),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd,
                  vertical: AppTheme.spacingSm,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                  color: appColors.neonAccent.withOpacity(AppTheme.opacityGlass),
                  border: Border.all(color: appColors.neonAccent.withOpacity(AppTheme.opacityGlassBorder)),
                ),
                child: Text(
                  'Premium Feature',
                  style: text.labelMedium?.copyWith(color: appColors.neonAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
