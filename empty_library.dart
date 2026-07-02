import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class EmptyLibrary extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback? onClearFilters;

  const EmptyLibrary({super.key, this.hasFilters = false, this.onClearFilters});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colors.neonAccent.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFilters ? Icons.search_off : Icons.music_note,
                size: 44,
                color: colors.neonAccent.withOpacity(AppTheme.opacityHint),
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              hasFilters ? 'No Loops Found' : 'Your Library is Empty',
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              hasFilters
                  ? 'Try adjusting your filters or search query to find more loops.'
                  : 'Generate your first loop on the AI tab and it will appear here.',
              style: textTheme.bodyMedium?.copyWith(color: colors.subtleText),
              textAlign: TextAlign.center,
            ),
            if (hasFilters && onClearFilters != null) ...[
              const SizedBox(height: AppTheme.spacingLg),
              GestureDetector(
                onTap: onClearFilters,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingLg,
                    vertical: AppTheme.spacingMd,
                  ),
                  decoration: BoxDecoration(
                    color: colors.neonAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(color: colors.neonAccent.withOpacity(0.4)),
                  ),
                  child: Text(
                    'Clear Filters',
                    style: textTheme.labelLarge?.copyWith(color: colors.neonAccent),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
