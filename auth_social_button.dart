import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class AuthSocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const AuthSocialButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;
    final isDisabled = onPressed == null;

    return Opacity(
      opacity: isDisabled ? AppTheme.opacityDisabled : 1.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Material(
            color: colors.glassBg,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: Container(
                height: AppTheme.buttonHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(color: colors.glassBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: AppTheme.iconLg, color: Theme.of(context).colorScheme.onSurface),
                    const SizedBox(width: AppTheme.spacingSm),
                    Text(
                      label,
                      style: textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
