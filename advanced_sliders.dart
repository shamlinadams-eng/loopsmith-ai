import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../common/glass_card.dart';
import '../common/section_header.dart';

class AdvancedSliders extends StatelessWidget {
  final double complexity;
  final double swing;
  final double humanization;
  final double vintageModern;
  final double cleanDirty;
  final ValueChanged<double> onComplexityChanged;
  final ValueChanged<double> onSwingChanged;
  final ValueChanged<double> onHumanizationChanged;
  final ValueChanged<double> onVintageModernChanged;
  final ValueChanged<double> onCleanDirtyChanged;

  const AdvancedSliders({
    super.key,
    required this.complexity,
    required this.swing,
    required this.humanization,
    required this.vintageModern,
    required this.cleanDirty,
    required this.onComplexityChanged,
    required this.onSwingChanged,
    required this.onHumanizationChanged,
    required this.onVintageModernChanged,
    required this.onCleanDirtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Advanced Controls'),
          _SliderRow(
            label: 'Complexity',
            value: complexity,
            onChanged: onComplexityChanged,
            accentColor: appColors.neonAccent,
            appColors: appColors,
          ),
          _SliderRow(
            label: 'Swing',
            value: swing,
            onChanged: onSwingChanged,
            accentColor: appColors.neonSecondary,
            appColors: appColors,
          ),
          _SliderRow(
            label: 'Humanization',
            value: humanization,
            onChanged: onHumanizationChanged,
            accentColor: appColors.neonTertiary,
            appColors: appColors,
          ),
          _DualLabelSliderRow(
            leftLabel: 'Vintage',
            rightLabel: 'Modern',
            value: vintageModern,
            onChanged: onVintageModernChanged,
            accentColor: appColors.warning,
            appColors: appColors,
          ),
          _DualLabelSliderRow(
            leftLabel: 'Clean',
            rightLabel: 'Dirty',
            value: cleanDirty,
            onChanged: onCleanDirtyChanged,
            accentColor: appColors.neonAccent,
            appColors: appColors,
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final Color accentColor;
  final AppColorsExtension appColors;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.accentColor,
    required this.appColors,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingXs),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: text.labelSmall?.copyWith(color: appColors.subtleText)),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: accentColor,
                inactiveTrackColor: appColors.glassBorder,
                thumbColor: accentColor,
                overlayColor: accentColor.withOpacity(AppTheme.opacityGlass),
                trackHeight: 3,
              ),
              child: Slider(value: value, onChanged: onChanged),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '${(value * 100).round()}%',
              style: text.labelSmall?.copyWith(color: accentColor),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _DualLabelSliderRow extends StatelessWidget {
  final String leftLabel;
  final String rightLabel;
  final double value;
  final ValueChanged<double> onChanged;
  final Color accentColor;
  final AppColorsExtension appColors;

  const _DualLabelSliderRow({
    required this.leftLabel,
    required this.rightLabel,
    required this.value,
    required this.onChanged,
    required this.accentColor,
    required this.appColors,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingXs),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(leftLabel, style: text.labelSmall?.copyWith(color: appColors.subtleText)),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: accentColor,
                inactiveTrackColor: appColors.glassBorder,
                thumbColor: accentColor,
                overlayColor: accentColor.withOpacity(AppTheme.opacityGlass),
                trackHeight: 3,
              ),
              child: Slider(value: value, onChanged: onChanged),
            ),
          ),
          SizedBox(
            width: 56,
            child: Text(
              rightLabel,
              style: text.labelSmall?.copyWith(color: appColors.subtleText),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
