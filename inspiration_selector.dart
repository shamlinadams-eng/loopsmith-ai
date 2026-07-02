import 'package:flutter/material.dart';

import '../../models/generation_params.dart';
import '../../theme/theme.dart';
import '../common/glass_card.dart';
import '../common/section_header.dart';

class InspirationSelector extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;

  const InspirationSelector({super.key, this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;
    final text = Theme.of(context).textTheme;

    return GlassCard(
      glowColor: appColors.neonTertiary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Inspiration Mode',
            trailing: selected != null
                ? GestureDetector(
                    onTap: () => onChanged(null),
                    child: Text('Clear', style: text.labelSmall?.copyWith(color: appColors.neonAccent)),
                  )
                : null,
          ),
          Text(
            'Capture production characteristics without copying',
            style: text.bodySmall?.copyWith(color: appColors.subtleText),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Wrap(
            spacing: AppTheme.spacingSm,
            runSpacing: AppTheme.spacingSm,
            children: GenerationParams.inspirations.map((name) {
              final isSelected = name == selected;
              return ChoiceChip(
                label: Text(
                  name,
                  style: text.labelSmall?.copyWith(
                    color: isSelected ? appColors.neonTertiary : appColors.subtleText,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => onChanged(isSelected ? null : name),
                backgroundColor: appColors.glassBg,
                selectedColor: appColors.neonTertiary.withOpacity(0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  side: BorderSide(
                    color: isSelected ? appColors.neonTertiary.withOpacity(AppTheme.opacityHint) : appColors.glassBorder,
                  ),
                ),
                showCheckmark: false,
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
