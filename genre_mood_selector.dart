import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../common/glass_card.dart';
import '../common/section_header.dart';

class GenreMoodSelector extends StatelessWidget {
  final String selectedGenre;
  final String selectedMood;
  final ValueChanged<String> onGenreChanged;
  final ValueChanged<String> onMoodChanged;
  final List<String> genres;
  final List<String> moods;

  const GenreMoodSelector({
    super.key,
    required this.selectedGenre,
    required this.selectedMood,
    required this.onGenreChanged,
    required this.onMoodChanged,
    required this.genres,
    required this.moods,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;
    final text = Theme.of(context).textTheme;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Genre'),
          _buildChipWrap(context, genres, selectedGenre, onGenreChanged, appColors, text),
          const SizedBox(height: AppTheme.spacingMd),
          const SectionHeader(title: 'Mood'),
          _buildChipWrap(context, moods, selectedMood, onMoodChanged, appColors, text),
        ],
      ),
    );
  }

  Widget _buildChipWrap(
    BuildContext context,
    List<String> items,
    String selected,
    ValueChanged<String> onSelected,
    AppColorsExtension appColors,
    TextTheme text,
  ) {
    return Wrap(
      spacing: AppTheme.spacingSm,
      runSpacing: AppTheme.spacingSm,
      children: items.map((item) {
        final isSelected = item == selected;
        return ChoiceChip(
          label: Text(
            item,
            style: text.labelSmall?.copyWith(
              color: isSelected ? appColors.neonAccent : appColors.subtleText,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          selected: isSelected,
          onSelected: (_) => onSelected(item),
          backgroundColor: appColors.glassBg,
          selectedColor: appColors.neonAccent.withOpacity(0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            side: BorderSide(
              color: isSelected ? appColors.neonAccent.withOpacity(AppTheme.opacityHint) : appColors.glassBorder,
              width: isSelected ? AppTheme.borderSelected : AppTheme.borderDefault,
            ),
          ),
          showCheckmark: false,
          visualDensity: VisualDensity.compact,
        );
      }).toList(),
    );
  }
}
