import 'package:flutter/material.dart';

import '../../models/generation_params.dart';
import '../../theme/theme.dart';
import '../common/glass_card.dart';

class PromptInputCard extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  const PromptInputCard({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;
    final text = Theme.of(context).textTheme;

    return GlassCard(
      glowColor: appColors.neonSecondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: AppTheme.iconSm, color: appColors.neonSecondary),
              const SizedBox(width: AppTheme.spacingSm),
              Text('Describe your loop', style: text.titleSmall),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          TextField(
            controller: controller,
            onChanged: onChanged,
            maxLines: 2,
            style: text.bodyMedium,
            decoration: InputDecoration(
              hintText: hintText,
              filled: true,
              fillColor: appColors.glassBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                borderSide: BorderSide(color: appColors.glassBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                borderSide: BorderSide(color: appColors.glassBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                borderSide: BorderSide(color: appColors.neonSecondary, width: AppTheme.borderSelected),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          SizedBox(
            height: AppTheme.chipHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: GenerationParams.promptExamples.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppTheme.spacingSm),
              itemBuilder: (context, index) {
                final example = GenerationParams.promptExamples[index];
                return ActionChip(
                  label: Text(
                    example,
                    style: text.labelSmall?.copyWith(color: appColors.subtleText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  backgroundColor: appColors.glassBg,
                  side: BorderSide(color: appColors.glassBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  onPressed: () {
                    controller.text = example;
                    onChanged(example);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
