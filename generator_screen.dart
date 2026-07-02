import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/generation_params.dart';
import '../providers/generator_provider.dart';
import '../services/audio_player_service.dart';
import '../theme/theme.dart';
import '../widgets/generator/advanced_sliders.dart';
import '../widgets/generator/generation_status.dart';
import '../widgets/generator/genre_mood_selector.dart';
import '../widgets/generator/inspiration_selector.dart';
import '../widgets/generator/params_grid.dart';
import '../widgets/generator/prompt_input_card.dart';
import '../widgets/generator/smart_controls.dart';
import '../widgets/generator/waveform_player.dart';
import '../widgets/common/neon_button.dart';

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  final _promptController = TextEditingController();

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GeneratorProvider>();
    // Watch AudioPlayerService directly so the waveform animates in real time
    final audio = context.watch<AudioPlayerService>();

    final loop = provider.lastGenerated;
    final isThisLoopPlaying = audio.isPlaying && audio.currentLoop?.id == loop?.id;
    final progress = (audio.currentLoop?.id == loop?.id) ? audio.progress : 0.0;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GenerationStatus(remaining: provider.remainingGenerations),
              const SizedBox(height: AppTheme.spacingMd),
              PromptInputCard(
                controller: _promptController,
                hintText: provider.randomPromptHint,
                onChanged: provider.updatePrompt,
              ),
              const SizedBox(height: AppTheme.spacingSm),
              GenreMoodSelector(
                selectedGenre: provider.params.genre,
                selectedMood: provider.params.mood,
                onGenreChanged: provider.updateGenre,
                onMoodChanged: provider.updateMood,
                genres: GenerationParams.genres,
                moods: GenerationParams.moods,
              ),
              const SizedBox(height: AppTheme.spacingSm),
              ParamsGrid(
                bpm: provider.params.bpm,
                selectedKey: provider.params.key,
                selectedScale: provider.params.scale,
                bars: provider.params.bars,
                instrument: provider.params.instrument,
                onBpmChanged: provider.updateBpm,
                onKeyChanged: provider.updateKey,
                onScaleChanged: provider.updateScale,
                onBarsChanged: provider.updateBars,
                onInstrumentChanged: provider.updateInstrument,
              ),
              const SizedBox(height: AppTheme.spacingSm),
              _AdvancedToggle(
                isExpanded: provider.showAdvanced,
                onToggle: provider.toggleAdvanced,
              ),
              if (provider.showAdvanced) ...[
                const SizedBox(height: AppTheme.spacingSm),
                AdvancedSliders(
                  complexity: provider.params.complexity,
                  swing: provider.params.swing,
                  humanization: provider.params.humanization,
                  vintageModern: provider.params.vintageModern,
                  cleanDirty: provider.params.cleanDirty,
                  onComplexityChanged: provider.updateComplexity,
                  onSwingChanged: provider.updateSwing,
                  onHumanizationChanged: provider.updateHumanization,
                  onVintageModernChanged: provider.updateVintageModern,
                  onCleanDirtyChanged: provider.updateCleanDirty,
                ),
                const SizedBox(height: AppTheme.spacingSm),
                InspirationSelector(
                  selected: provider.params.inspiration,
                  onChanged: provider.updateInspiration,
                ),
              ],
              const SizedBox(height: AppTheme.spacingMd),
              NeonButton(
                label: 'Generate Loop',
                icon: Icons.auto_awesome,
                isLoading: provider.isGenerating,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  provider.generate();
                },
              ),
              if (loop != null) ...[
                const SizedBox(height: AppTheme.spacingMd),
                if (audio.isLoading && audio.currentLoop?.id == loop.id)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).extension<AppColorsExtension>()!.neonAccent,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        Text(
                          'Loading audio…',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).extension<AppColorsExtension>()!.subtleText,
                          ),
                        ),
                      ],
                    ),
                  ),
                WaveformPlayer(
                  loop: loop,
                  isPlaying: isThisLoopPlaying,
                  progress: progress,
                  onTogglePlayback: () {
                    HapticFeedback.lightImpact();
                    provider.togglePlayback();
                  },
                ),
                const SizedBox(height: AppTheme.spacingSm),
                SmartControls(onControlSelected: (control) {
                  HapticFeedback.lightImpact();
                  provider.applySmartControl(control);
                }),
              ],
              const SizedBox(height: AppTheme.spacingXl),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdvancedToggle extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const _AdvancedToggle({required this.isExpanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;
    final text = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onToggle,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            size: AppTheme.iconSm,
            color: appColors.subtleText,
          ),
          const SizedBox(width: AppTheme.spacingXs),
          Text(
            isExpanded ? 'Hide advanced' : 'Show advanced controls',
            style: text.labelSmall?.copyWith(color: appColors.subtleText),
          ),
        ],
      ),
    );
  }
}
