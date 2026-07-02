import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/loop_model.dart';
import '../../providers/browser_provider.dart';
import '../../services/audio_player_service.dart'; // used via context.watch in build
import '../../theme/theme.dart';
import '../../widgets/common/glass_card.dart';

class LoopPlayerSheet extends StatefulWidget {
  final BrowserProvider provider;

  const LoopPlayerSheet({super.key, required this.provider});

  @override
  State<LoopPlayerSheet> createState() => _LoopPlayerSheetState();
}

class _LoopPlayerSheetState extends State<LoopPlayerSheet>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    // Audio is already started by BrowserProvider.openPlayer() before this
    // sheet is shown — no need to call loadAndPlay again here. A second call
    // mid-buffer would cancel and restart the stream, causing silence.
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handlePlayToggle() {
    context.read<AudioPlayerService>().togglePlayback();
  }

  @override
  Widget build(BuildContext context) {
    final prov = widget.provider;
    final loop = prov.selectedLoop;
    if (loop == null) return const SizedBox.shrink();

    final audio = context.watch<AudioPlayerService>();
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scroll) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusXl),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: AppTheme.spacingSm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.glassBorder,
                borderRadius: BorderRadius.circular(AppTheme.radiusRound),
              ),
            ),
            if (audio.isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.neonAccent,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    Text('Loading audio…', style: textTheme.labelSmall?.copyWith(color: colors.subtleText)),
                  ],
                ),
              ),
            if (audio.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd,
                  vertical: AppTheme.spacingXs,
                ),
                child: Text(
                  audio.error!,
                  style: textTheme.labelSmall?.copyWith(color: colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                children: [
                  _PlayerHeader(loop: loop, prov: prov, colors: colors),
                  const SizedBox(height: AppTheme.spacingMd),
                  _WaveformSection(
                    loop: loop,
                    prov: prov,
                    audio: audio,
                    colors: colors,
                    pulseController: _pulseController,
                    onPlayToggle: _handlePlayToggle,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  _SpeedSelector(prov: prov, audio: audio, colors: colors, textTheme: textTheme),
                  const SizedBox(height: AppTheme.spacingMd),
                  _PitchControl(prov: prov, colors: colors, textTheme: textTheme),
                  const SizedBox(height: AppTheme.spacingMd),
                  _EffectsRow(prov: prov, colors: colors, textTheme: textTheme),
                  const SizedBox(height: AppTheme.spacingMd),
                  _LoopInfo(loop: loop, colors: colors, textTheme: textTheme),
                  const SizedBox(height: AppTheme.spacingMd),
                  _ExportFromPlayer(loop: loop, colors: colors, textTheme: textTheme),
                  const SizedBox(height: AppTheme.spacingXl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerHeader extends StatelessWidget {
  final LoopModel loop;
  final BrowserProvider prov;
  final AppColorsExtension colors;

  const _PlayerHeader({required this.loop, required this.prov, required this.colors});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        GestureDetector(
          onTap: () => prov.closePlayer(),
          child: Icon(Icons.keyboard_arrow_down, color: colors.subtleText, size: AppTheme.iconLg),
        ),
        const SizedBox(width: AppTheme.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Now Playing', style: textTheme.labelSmall?.copyWith(color: colors.subtleText)),
              Text(loop.name, style: textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => prov.toggleFavorite(loop.id),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              loop.isFavorite ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(loop.isFavorite),
              color: loop.isFavorite ? colors.neonSecondary : colors.subtleText,
              size: AppTheme.iconMd,
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingSm),
        GestureDetector(
          onTap: () => _showExportSheet(context, loop, colors),
          child: Icon(Icons.ios_share, color: colors.subtleText, size: AppTheme.iconMd),
        ),
      ],
    );
  }

  void _showExportSheet(BuildContext context, LoopModel loop, AppColorsExtension colors) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExportSheet(loop: loop),
    );
  }
}

class _WaveformSection extends StatelessWidget {
  final LoopModel loop;
  final BrowserProvider prov;
  final AudioPlayerService audio;
  final AppColorsExtension colors;
  final AnimationController pulseController;
  final VoidCallback onPlayToggle;

  const _WaveformSection({
    required this.loop,
    required this.prov,
    required this.audio,
    required this.colors,
    required this.pulseController,
    required this.onPlayToggle,
  });

  String _fmt(Duration d) {
    final s = d.inSeconds;
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GlassCard(
      glowColor: audio.isPlaying ? colors.neonAccent : null,
      child: Column(
        children: [
          GestureDetector(
            onTapDown: (d) {
              final box = context.findRenderObject() as RenderBox?;
              if (box != null) {
                final localPos = box.globalToLocal(d.globalPosition);
                audio.seekTo((localPos.dx / box.size.width).clamp(0.0, 1.0));
              }
            },
            child: SizedBox(
              height: 80,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                // RepaintBoundary isolates waveform repaints from the rest of
                // the sheet, preventing full-subtree invalidation on every frame.
                child: RepaintBoundary(
                  child: AnimatedBuilder(
                    // Only animate when playing — stops 60fps rebuilds at rest.
                    animation: audio.isPlaying
                        ? pulseController
                        : const AlwaysStoppedAnimation(0.0),
                    builder: (_, __) => CustomPaint(
                      painter: _DetailedWaveformPainter(
                        seed: loop.id.hashCode,
                        progress: audio.progress,
                        activeColor: colors.neonAccent,
                        inactiveColor: colors.neonAccent.withOpacity(0.25),
                        isPlaying: audio.isPlaying,
                        pulse: audio.isPlaying ? pulseController.value : 0.0,
                        isReversed: prov.isReversed,
                      ),
                      size: Size.infinite,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_fmt(audio.position), style: textTheme.labelSmall?.copyWith(color: colors.subtleText)),
              Text(_fmt(audio.duration), style: textTheme.labelSmall?.copyWith(color: colors.subtleText)),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PlayBtn(icon: Icons.skip_previous, onTap: () => audio.seekTo(0), colors: colors),
              const SizedBox(width: AppTheme.spacingLg),
              _MainPlayButton(isPlaying: audio.isPlaying, onTap: onPlayToggle, colors: colors),
              const SizedBox(width: AppTheme.spacingLg),
              _PlayBtn(icon: Icons.skip_next, onTap: () => audio.seekTo(1), colors: colors),
            ],
          ),
        ],
      ),
    );
  }
}

class _MainPlayButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;
  final AppColorsExtension colors;

  const _MainPlayButton({required this.isPlaying, required this.onTap, required this.colors});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: colors.neonAccent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colors.neonAccent.withOpacity(AppTheme.opacityGlow),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          color: const Color(0xFF0A0A0F),
          size: AppTheme.iconLg,
        ),
      ),
    );
  }
}

class _PlayBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final AppColorsExtension colors;

  const _PlayBtn({required this.icon, required this.onTap, required this.colors});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: colors.subtleText, size: AppTheme.iconLg),
    );
  }
}

class _SpeedSelector extends StatelessWidget {
  final BrowserProvider prov;
  final AudioPlayerService audio;
  final AppColorsExtension colors;
  final TextTheme textTheme;

  const _SpeedSelector({
    required this.prov,
    required this.audio,
    required this.colors,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final speeds = [0.5, 0.75, 1.0, 1.5, 2.0];
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Playback Speed', style: textTheme.labelMedium?.copyWith(color: colors.subtleText)),
          const SizedBox(height: AppTheme.spacingSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: speeds.map((s) {
              final isSelected = (audio.speed - s).abs() < 0.01;
              return GestureDetector(
                onTap: () => audio.setSpeed(s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 52,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected ? colors.neonTertiary.withOpacity(0.15) : colors.glassBg,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    border: Border.all(
                      color: isSelected ? colors.neonTertiary : colors.glassBorder,
                      width: isSelected ? AppTheme.borderSelected : AppTheme.borderDefault,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${s}x',
                      style: textTheme.labelMedium?.copyWith(
                        color: isSelected ? colors.neonTertiary : colors.subtleText,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _PitchControl extends StatelessWidget {
  final BrowserProvider prov;
  final AppColorsExtension colors;
  final TextTheme textTheme;

  const _PitchControl({required this.prov, required this.colors, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    final pitch = prov.pitchShift;
    final pitchLabel = pitch == 0 ? '±0' : (pitch > 0 ? '+${pitch.toStringAsFixed(1)}' : pitch.toStringAsFixed(1));

    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Pitch Shift', style: textTheme.labelMedium?.copyWith(color: colors.subtleText)),
              const Spacer(),
              GestureDetector(
                onTap: prov.resetPitch,
                child: Text('Reset', style: textTheme.labelSmall?.copyWith(color: colors.neonAccent)),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Row(
            children: [
              _PitchBtn(label: '−2', onTap: () => prov.adjustPitch(-2), colors: colors),
              const SizedBox(width: AppTheme.spacingSm),
              _PitchBtn(label: '−1', onTap: () => prov.adjustPitch(-1), colors: colors),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingXs),
                decoration: BoxDecoration(
                  color: colors.neonSecondary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(color: colors.neonSecondary.withOpacity(0.4)),
                ),
                child: Text(
                  '$pitchLabel st',
                  style: textTheme.titleSmall?.copyWith(color: colors.neonSecondary),
                ),
              ),
              const Spacer(),
              _PitchBtn(label: '+1', onTap: () => prov.adjustPitch(1), colors: colors),
              const SizedBox(width: AppTheme.spacingSm),
              _PitchBtn(label: '+2', onTap: () => prov.adjustPitch(2), colors: colors),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: colors.neonSecondary,
              inactiveTrackColor: colors.glassBorder,
              thumbColor: colors.neonSecondary,
              overlayColor: colors.neonSecondary.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              trackHeight: 3,
            ),
            child: Slider(
              value: prov.pitchShift,
              min: -12,
              max: 12,
              divisions: 24,
              onChanged: (v) => prov.adjustPitch(v - prov.pitchShift),
            ),
          ),
        ],
      ),
    );
  }
}

class _PitchBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final AppColorsExtension colors;

  const _PitchBtn({required this.label, required this.onTap, required this.colors});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 36,
        decoration: BoxDecoration(
          color: colors.glassBg,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(color: colors.glassBorder),
        ),
        child: Center(
          child: Text(label, style: Theme.of(context).textTheme.labelMedium),
        ),
      ),
    );
  }
}

class _EffectsRow extends StatelessWidget {
  final BrowserProvider prov;
  final AppColorsExtension colors;
  final TextTheme textTheme;

  const _EffectsRow({required this.prov, required this.colors, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Effects', style: textTheme.labelMedium?.copyWith(color: colors.subtleText)),
          const SizedBox(height: AppTheme.spacingMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _EffectToggle(
                icon: Icons.swap_horiz,
                label: 'Reverse',
                isActive: prov.isReversed,
                onTap: prov.toggleReverse,
                colors: colors,
              ),
              _EffectToggle(
                icon: Icons.trending_up,
                label: 'Fade In',
                isActive: prov.isFadeIn,
                onTap: prov.toggleFadeIn,
                colors: colors,
              ),
              _EffectToggle(
                icon: Icons.trending_down,
                label: 'Fade Out',
                isActive: prov.isFadeOut,
                onTap: prov.toggleFadeOut,
                colors: colors,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EffectToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final AppColorsExtension colors;

  const _EffectToggle({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accent = colors.neonTertiary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 90,
        height: 72,
        decoration: BoxDecoration(
          color: isActive ? accent.withOpacity(0.15) : colors.glassBg,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isActive ? accent : colors.glassBorder,
            width: isActive ? AppTheme.borderSelected : AppTheme.borderDefault,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isActive ? accent : colors.subtleText, size: AppTheme.iconMd),
            const SizedBox(height: AppTheme.spacingXs),
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: isActive ? accent : colors.subtleText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoopInfo extends StatelessWidget {
  final LoopModel loop;
  final AppColorsExtension colors;
  final TextTheme textTheme;

  const _LoopInfo({required this.loop, required this.colors, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Loop Details', style: textTheme.labelMedium?.copyWith(color: colors.subtleText)),
          const SizedBox(height: AppTheme.spacingMd),
          Wrap(
            spacing: AppTheme.spacingSm,
            runSpacing: AppTheme.spacingSm,
            children: [
              _InfoChip(label: loop.genre, icon: Icons.music_note, colors: colors),
              _InfoChip(label: loop.mood, icon: Icons.mood, colors: colors),
              _InfoChip(label: '${loop.bpm} BPM', icon: Icons.speed, colors: colors),
              _InfoChip(label: '${loop.key} ${loop.scale}', icon: Icons.piano, colors: colors),
              _InfoChip(label: '${loop.bars} bars', icon: Icons.grid_on, colors: colors),
              _InfoChip(label: loop.instrument, icon: Icons.headphones, colors: colors),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final AppColorsExtension colors;

  const _InfoChip({required this.label, required this.icon, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: AppTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: colors.glassBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: colors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppTheme.iconSm, color: colors.neonAccent),
          const SizedBox(width: AppTheme.spacingXs),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _ExportFromPlayer extends StatelessWidget {
  final LoopModel loop;
  final AppColorsExtension colors;
  final TextTheme textTheme;

  const _ExportFromPlayer({required this.loop, required this.colors, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => ExportSheet(loop: loop),
        );
      },
      child: Container(
        height: AppTheme.buttonHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: colors.neonAccent.withOpacity(0.5)),
          color: colors.neonAccent.withOpacity(0.08),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.download, color: colors.neonAccent, size: AppTheme.iconMd),
            const SizedBox(width: AppTheme.spacingSm),
            Text(
              'Export Loop',
              style: textTheme.labelLarge?.copyWith(color: colors.neonAccent),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailedWaveformPainter extends CustomPainter {
  final int seed;
  final double progress;
  final Color activeColor;
  final Color inactiveColor;
  final bool isPlaying;
  final double pulse;
  final bool isReversed;

  const _DetailedWaveformPainter({
    required this.seed,
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
    required this.isPlaying,
    required this.pulse,
    required this.isReversed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(seed);
    final bars = 60;
    final barW = size.width / (bars * 1.6);
    final gap = size.width / bars - barW;

    for (int i = 0; i < bars; i++) {
      final normI = isReversed ? (bars - 1 - i) / (bars - 1) : i / (bars - 1);
      final isPast = normI <= progress;
      final amplitudeMod = isPast && isPlaying ? (1.0 + pulse * 0.08) : 1.0;
      final h = (rng.nextDouble() * 0.75 + 0.1) * size.height * amplitudeMod;
      final x = i * (barW + gap);
      final top = (size.height - h) / 2;

      final paint = Paint()
        ..color = isPast ? activeColor : inactiveColor
        ..strokeWidth = barW
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(x + barW / 2, top),
        Offset(x + barW / 2, top + h),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DetailedWaveformPainter old) =>
      old.progress != progress || old.pulse != pulse || old.isPlaying != isPlaying;
}

// ─── Export Sheet ────────────────────────────────────────────────────────────

class ExportSheet extends StatefulWidget {
  final LoopModel loop;

  const ExportSheet({super.key, required this.loop});

  @override
  State<ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<ExportSheet> {
  String? _exporting;

  Future<void> _export(String format) async {
    setState(() => _exporting = format);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _exporting = null);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Loop exported as $format — ready for download!'),
        backgroundColor: Theme.of(context).extension<AppColorsExtension>()!.neonTertiary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final formats = [
      _ExportFormat('WAV', Icons.audio_file, 'Lossless 24-bit audio', colors.neonAccent, false),
      _ExportFormat('MP3', Icons.music_video, '320kbps compressed', colors.neonAccent, false),
      _ExportFormat('MIDI', Icons.piano, 'MIDI note data', colors.neonSecondary, false),
      _ExportFormat('Stems (ZIP)', Icons.layers, 'Individual stem files', colors.neonSecondary, true),
      _ExportFormat('FL Studio', Icons.folder_special, '.flp project file', colors.neonTertiary, true),
      _ExportFormat('Ableton', Icons.library_music, '.als project file', colors.neonTertiary, true),
      _ExportFormat('Logic', Icons.apple, '.logicx package', colors.warning, true),
      _ExportFormat('ZIP (All)', Icons.archive, 'All formats bundled', colors.warning, true),
    ];

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      ),
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.glassBorder,
                borderRadius: BorderRadius.circular(AppTheme.radiusRound),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Text('Export Loop', style: textTheme.titleLarge),
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            widget.loop.name,
            style: textTheme.bodySmall?.copyWith(color: colors.subtleText),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppTheme.spacingLg),
          ...formats.map((f) => _ExportTile(
                format: f,
                isExporting: _exporting == f.label,
                onTap: () => _export(f.label),
                colors: colors,
                textTheme: textTheme,
              )),
          const SizedBox(height: AppTheme.spacingMd),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: colors.neonSecondary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: colors.neonSecondary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.lock, size: AppTheme.iconSm, color: colors.neonSecondary),
                const SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: Text(
                    'Stems & DAW project exports require LoopSmith AI Premium.',
                    style: textTheme.bodySmall?.copyWith(color: colors.neonSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingXl),
        ],
      ),
    );
  }
}

class _ExportFormat {
  final String label;
  final IconData icon;
  final String subtitle;
  final Color color;
  final bool isPremium;

  const _ExportFormat(this.label, this.icon, this.subtitle, this.color, this.isPremium);
}

class _ExportTile extends StatelessWidget {
  final _ExportFormat format;
  final bool isExporting;
  final VoidCallback onTap;
  final AppColorsExtension colors;
  final TextTheme textTheme;

  const _ExportTile({
    required this.format,
    required this.isExporting,
    required this.onTap,
    required this.colors,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingXs),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingSm + AppTheme.spacingXs,
          ),
          decoration: BoxDecoration(
            color: colors.cardBg,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: colors.glassBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: format.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(format.icon, color: format.color, size: AppTheme.iconMd),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(format.label, style: textTheme.titleSmall),
                        if (format.isPremium) ...[
                          const SizedBox(width: AppTheme.spacingXs),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.neonSecondary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                            ),
                            child: Text(
                              'PRO',
                              style: textTheme.labelSmall?.copyWith(
                                color: colors.neonSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      format.subtitle,
                      style: textTheme.bodySmall?.copyWith(color: colors.subtleText),
                    ),
                  ],
                ),
              ),
              if (isExporting)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(format.color),
                  ),
                )
              else
                Icon(Icons.download_outlined, color: colors.subtleText, size: AppTheme.iconMd),
            ],
          ),
        ),
      ),
    );
  }
}
