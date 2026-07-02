import 'package:flutter/material.dart';

import '../../providers/browser_provider.dart';
import '../../theme/theme.dart';

class BrowserFilterBar extends StatelessWidget {
  final BrowserProvider provider;

  const BrowserFilterBar({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
          child: Row(
            children: [
              _FilterChip(
                label: 'All',
                isSelected: provider.filter == BrowserFilter.all,
                onTap: () => provider.updateFilter(BrowserFilter.all),
                colors: colors,
              ),
              const SizedBox(width: AppTheme.spacingSm),
              _FilterChip(
                label: '♥ Favorites',
                isSelected: provider.filter == BrowserFilter.favorites,
                onTap: () => provider.updateFilter(BrowserFilter.favorites),
                colors: colors,
                selectedColor: colors.neonSecondary,
              ),
              const SizedBox(width: AppTheme.spacingSm),
              _FilterChip(
                label: '🎛 My Samples',
                isSelected: provider.filter == BrowserFilter.catalog,
                onTap: () => provider.updateFilter(BrowserFilter.catalog),
                colors: colors,
                selectedColor: colors.neonTertiary,
              ),
              const Spacer(),
              _SortButton(provider: provider, colors: colors, textTheme: textTheme),
            ],
          ),
        ),
        if (provider.availableGenres.isNotEmpty) ...[
          const SizedBox(height: AppTheme.spacingSm),
          SizedBox(
            height: AppTheme.chipHeight,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
              scrollDirection: Axis.horizontal,
              itemCount: provider.availableGenres.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppTheme.spacingXs),
              itemBuilder: (context, i) {
                final genre = provider.availableGenres[i];
                return _FilterChip(
                  label: genre,
                  isSelected: provider.selectedGenre == genre,
                  onTap: () => provider.selectGenre(genre),
                  colors: colors,
                );
              },
            ),
          ),
        ],
        if (provider.availableMoods.isNotEmpty) ...[
          const SizedBox(height: AppTheme.spacingXs),
          SizedBox(
            height: AppTheme.chipHeight,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
              scrollDirection: Axis.horizontal,
              itemCount: provider.availableMoods.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppTheme.spacingXs),
              itemBuilder: (context, i) {
                final mood = provider.availableMoods[i];
                return _FilterChip(
                  label: mood,
                  isSelected: provider.selectedMood == mood,
                  onTap: () => provider.selectMood(mood),
                  colors: colors,
                  selectedColor: colors.neonSecondary,
                );
              },
            ),
          ),
        ],
        if (provider.hasActiveFilters)
          Padding(
            padding: const EdgeInsets.only(
              top: AppTheme.spacingXs,
              left: AppTheme.spacingMd,
              right: AppTheme.spacingMd,
            ),
            child: Row(
              children: [
                Icon(Icons.filter_list, size: AppTheme.iconSm, color: colors.warning),
                const SizedBox(width: AppTheme.spacingXs),
                Text(
                  '${provider.filteredLoops.length} results',
                  style: textTheme.labelSmall?.copyWith(color: colors.warning),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: provider.clearFilters,
                  child: Text(
                    'Clear all',
                    style: textTheme.labelSmall?.copyWith(color: colors.neonAccent),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final AppColorsExtension colors;
  final Color? selectedColor;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colors,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = selectedColor ?? colors.neonAccent;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: AppTheme.chipHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: isSelected ? accent.withOpacity(0.15) : colors.glassBg,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(
            color: isSelected ? accent : colors.glassBorder,
            width: isSelected ? AppTheme.borderSelected : AppTheme.borderDefault,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isSelected ? accent : colors.subtleText,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
          ),
        ),
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  final BrowserProvider provider;
  final AppColorsExtension colors;
  final TextTheme textTheme;

  const _SortButton({
    required this.provider,
    required this.colors,
    required this.textTheme,
  });

  String get _sortLabel {
    switch (provider.sortBy) {
      case BrowserSortBy.date:
        return 'Date';
      case BrowserSortBy.bpm:
        return 'BPM';
      case BrowserSortBy.key:
        return 'Key';
      case BrowserSortBy.mood:
        return 'Mood';
      case BrowserSortBy.genre:
        return 'Genre';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF12121A),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
        ),
        builder: (_) => _SortSheet(provider: provider, colors: colors),
      ),
      child: Container(
        height: AppTheme.chipHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: colors.glassBg,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(color: colors.glassBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sort, size: AppTheme.iconSm, color: colors.subtleText),
            const SizedBox(width: AppTheme.spacingXs),
            Text(
              _sortLabel,
              style: textTheme.labelMedium?.copyWith(color: colors.subtleText),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortSheet extends StatelessWidget {
  final BrowserProvider provider;
  final AppColorsExtension colors;

  const _SortSheet({required this.provider, required this.colors});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sort By', style: textTheme.titleMedium),
          const SizedBox(height: AppTheme.spacingMd),
          ...BrowserSortBy.values.map((s) {
            final isSelected = provider.sortBy == s;
            final label = s.name[0].toUpperCase() + s.name.substring(1);
            return ListTile(
              onTap: () {
                provider.updateSortBy(s);
                Navigator.pop(context);
              },
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected ? colors.neonAccent : colors.subtleText,
                size: AppTheme.iconMd,
              ),
              title: Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  color: isSelected ? colors.neonAccent : null,
                  fontWeight: isSelected ? FontWeight.w600 : null,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
