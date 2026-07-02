import 'package:flutter/material.dart';

import '../../models/generation_params.dart';
import '../../theme/theme.dart';
import '../common/glass_card.dart';
import '../common/section_header.dart';

class ParamsGrid extends StatelessWidget {
  final int bpm;
  final String selectedKey;
  final String selectedScale;
  final int bars;
  final String instrument;
  final ValueChanged<int> onBpmChanged;
  final ValueChanged<String> onKeyChanged;
  final ValueChanged<String> onScaleChanged;
  final ValueChanged<int> onBarsChanged;
  final ValueChanged<String> onInstrumentChanged;

  const ParamsGrid({
    super.key,
    required this.bpm,
    required this.selectedKey,
    required this.selectedScale,
    required this.bars,
    required this.instrument,
    required this.onBpmChanged,
    required this.onKeyChanged,
    required this.onScaleChanged,
    required this.onBarsChanged,
    required this.onInstrumentChanged,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;
    final text = Theme.of(context).textTheme;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Parameters'),
          // BPM
          Row(
            children: [
              Text('BPM', style: text.labelMedium?.copyWith(color: appColors.subtleText)),
              const SizedBox(width: AppTheme.spacingSm),
              Text('$bpm', style: text.titleSmall?.copyWith(color: appColors.neonAccent)),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: appColors.neonAccent,
                    inactiveTrackColor: appColors.glassBorder,
                    thumbColor: appColors.neonAccent,
                    overlayColor: appColors.neonAccent.withOpacity(AppTheme.opacityGlass),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: bpm.toDouble(),
                    min: 60,
                    max: 200,
                    divisions: 140,
                    onChanged: (v) => onBpmChanged(v.round()),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          // Key + Scale row
          Row(
            children: [
              Expanded(
                child: _ParamDropdown(
                  label: 'Key',
                  value: selectedKey,
                  items: GenerationParams.keys,
                  onChanged: onKeyChanged,
                  appColors: appColors,
                  textTheme: text,
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: _ParamDropdown(
                  label: 'Scale',
                  value: selectedScale,
                  items: GenerationParams.scales,
                  onChanged: onScaleChanged,
                  appColors: appColors,
                  textTheme: text,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          // Bars
          Row(
            children: [
              Text('Bars', style: text.labelMedium?.copyWith(color: appColors.subtleText)),
              const SizedBox(width: AppTheme.spacingSm),
              ...GenerationParams.barOptions.map((b) {
                final isSelected = b == bars;
                return Padding(
                  padding: const EdgeInsets.only(right: AppTheme.spacingXs),
                  child: ChoiceChip(
                    label: Text(
                      '$b',
                      style: text.labelSmall?.copyWith(
                        color: isSelected ? appColors.neonAccent : appColors.subtleText,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) => onBarsChanged(b),
                    backgroundColor: appColors.glassBg,
                    selectedColor: appColors.neonAccent.withOpacity(0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      side: BorderSide(
                        color: isSelected ? appColors.neonAccent.withOpacity(AppTheme.opacityHint) : appColors.glassBorder,
                      ),
                    ),
                    showCheckmark: false,
                    visualDensity: VisualDensity.compact,
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          // Instrument
          _ParamDropdown(
            label: 'Instrument',
            value: instrument,
            items: GenerationParams.instruments,
            onChanged: onInstrumentChanged,
            appColors: appColors,
            textTheme: text,
          ),
        ],
      ),
    );
  }
}

class _ParamDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final AppColorsExtension appColors;
  final TextTheme textTheme;

  const _ParamDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.appColors,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm, vertical: AppTheme.spacingXs),
      decoration: BoxDecoration(
        color: appColors.glassBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: appColors.glassBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          isDense: true,
          dropdownColor: appColors.cardBg,
          style: textTheme.bodySmall,
          icon: Icon(Icons.keyboard_arrow_down, size: AppTheme.iconSm, color: appColors.subtleText),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
