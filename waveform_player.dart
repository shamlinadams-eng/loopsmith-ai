import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/loop_model.dart';
import '../../theme/theme.dart';
import '../common/glass_card.dart';

class WaveformPlayer extends StatelessWidget {
  final LoopModel loop;
  final bool isPlaying;
  final double progress;
  final VoidCallback onTogglePlayback;

  const WaveformPlayer({
    super.key,
    required this.loop,
    required this.isPlaying,
    required this.progress,
    required this.onTogglePlayback,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;
    final text = Theme.of(context).textTheme;

    return GlassCard(
      glowColor: appColors.neonAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onTogglePlayback,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: appColors.neonAccent,
                    boxShadow: [
                      BoxShadow(
                        color: appColors.neonAccent.withOpacity(AppTheme.opacityGlow),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Theme.of(context).colorScheme.surface,
                    size: AppTheme.iconMd,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loop.name,
                      style: text.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${loop.genre} · ${loop.bpm} BPM · ${loop.key} ${loop.scale} · ${loop.bars} bars',
                      style: text.labelSmall?.copyWith(color: appColors.subtleText),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          RepaintBoundary(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              child: CustomPaint(
                size: const Size(double.infinity, 48),
                painter: _WaveformPainter(
                  seed: loop.id.hashCode,
                  progress: progress,
                  activeColor: appColors.neonAccent,
                  inactiveColor: appColors.glassBorder,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatTime(loop.durationSeconds * progress),
                style: text.labelSmall?.copyWith(color: appColors.subtleText),
              ),
              Text(
                _formatTime(loop.durationSeconds),
                style: text.labelSmall?.copyWith(color: appColors.subtleText),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PlayerAction(icon: Icons.loop, label: 'Loop', appColors: appColors),
              _PlayerAction(icon: Icons.swap_horiz, label: 'Reverse', appColors: appColors),
              _PlayerAction(icon: Icons.speed, label: '0.5x', appColors: appColors),
              _PlayerAction(icon: Icons.download, label: 'Export', appColors: appColors),
              _PlayerAction(icon: Icons.favorite_border, label: 'Save', appColors: appColors),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(double seconds) {
    final m = seconds ~/ 60;
    final s = (seconds % 60).toInt();
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class _PlayerAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppColorsExtension appColors;

  const _PlayerAction({
    required this.icon,
    required this.label,
    required this.appColors,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
      child: Column(
        children: [
          Icon(icon, size: AppTheme.iconSm, color: appColors.subtleText),
          const SizedBox(height: AppTheme.spacingXs),
          Text(label, style: text.labelSmall?.copyWith(color: appColors.subtleText, fontSize: 9)),
        ],
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final int seed;
  final double progress;
  final Color activeColor;
  final Color inactiveColor;

  _WaveformPainter({
    required this.seed,
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = 3.0;
    final gap = 2.0;
    final barCount = (size.width / (barWidth + gap)).floor();
    final progressIndex = (barCount * progress).floor();
    final random = math.Random(seed);

    for (var i = 0; i < barCount; i++) {
      final height = (random.nextDouble() * 0.7 + 0.3) * size.height;
      final x = i * (barWidth + gap);
      final y = (size.height - height) / 2;

      final paint = Paint()
        ..color = i < progressIndex ? activeColor : inactiveColor
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, height),
          const Radius.circular(1.5),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.seed != seed;
}
