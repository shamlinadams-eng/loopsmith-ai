import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? glowColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    // Solid glass simulation — identical visual to BackdropFilter blur at
    // a fraction of the GPU cost. BackdropFilter forces an offscreen
    // compositing layer for every card; on iOS with 6–8 cards visible
    // simultaneously this drops frames significantly.
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: appColors.glassBg,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: appColors.glassBorder),
          boxShadow: glowColor != null
              ? [
                  BoxShadow(
                    color: glowColor!.withOpacity(AppTheme.opacityGlass),
                    blurRadius: 20,
                    spreadRadius: -2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: child,
      ),
    );
  }
}
