import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class NeonButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const NeonButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;
    final text = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: appColors.neonAccent.withOpacity(AppTheme.opacityGlow),
            blurRadius: 16,
            spreadRadius: -4,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: appColors.neonAccent,
          foregroundColor: Theme.of(context).colorScheme.surface,
          disabledBackgroundColor: appColors.neonAccent.withOpacity(AppTheme.opacityDisabled),
        ),
        child: isLoading
            ? SizedBox(
                height: AppTheme.iconMd,
                width: AppTheme.iconMd,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Theme.of(context).colorScheme.surface,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: AppTheme.iconMd),
                    const SizedBox(width: AppTheme.spacingSm),
                  ],
                  Text(label, style: text.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.surface,
                    fontWeight: FontWeight.w700,
                  )),
                ],
              ),
      ),
    );
  }
}
