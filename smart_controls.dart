import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../common/glass_card.dart';
import '../common/section_header.dart';

class SmartControls extends StatelessWidget {
  final ValueChanged<String> onControlSelected;

  const SmartControls({super.key, required this.onControlSelected});

  static const _controls = [
    ('Regenerate', Icons.refresh),
    ('Mutate', Icons.hub),
    ('Simplify', Icons.remove_circle_outline),
    ('Make darker', Icons.dark_mode),
    ('More aggressive', Icons.bolt),
    ('More emotional', Icons.favorite),
    ('More jazzy', Icons.music_note),
    ('More cinematic', Icons.movie),
    ('Add tension', Icons.trending_up),
    ('Add bounce', Icons.sports_basketball),
    ('Add swing', Icons.waves),
    ('Randomize', Icons.casino),
  ];

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;
    final text = Theme.of(context).textTheme;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Smart Controls'),
          Wrap(
            spacing: AppTheme.spacingSm,
            runSpacing: AppTheme.spacingSm,
            children: _controls.map((c) {
              return ActionChip(
                avatar: Icon(c.$2, size: AppTheme.iconSm, color: appColors.neonAccent),
                label: Text(c.$1, style: text.labelSmall),
                backgroundColor: appColors.glassBg,
                side: BorderSide(color: appColors.glassBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                onPressed: () => onControlSelected(c.$1),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
