import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/loop_model.dart';
import '../../theme/theme.dart';

class LoopListTile extends StatelessWidget {
  final LoopModel loop;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback? onDelete;

  const LoopListTile({
    super.key,
    required this.loop,
    required this.onTap,
    required this.onFavorite,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;

    final isCatalog = loop.source == LoopSource.catalog;
    final waveColor = isCatalog ? colors.neonTertiary : colors.neonAccent;

    return GestureDetector(
      onTap: onTap,
      onLongPress: isCatalog && onDelete != null ? onDelete : null,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingXs,
        ),
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: colors.cardBg,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(
            color: isCatalog
                ? colors.neonTertiary.withOpacity(0.3)
                : colors.glassBorder,
          ),
        ),
        child: Row(
          children: [
            _MiniWaveform(seed: loop.id.hashCode, color: waveColor),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          loop.name,
                          style: textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCatalog) ...[
                        const SizedBox(width: AppTheme.spacingXs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingXs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.neonTertiary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                          ),
                          child: Text(
                            'MY SAMPLE',
                            style: textTheme.labelSmall?.copyWith(
                              color: colors.neonTertiary,
                              fontWeight: FontWeight.w700,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingXs),
                  Row(
                    children: [
                      _Tag(label: loop.genre, color: waveColor),
                      const SizedBox(width: AppTheme.spacingXs),
                      _Tag(label: loop.mood, color: colors.neonSecondary),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingXs),
                  Text(
                    '${loop.bpm} BPM  •  ${loop.key} ${loop.scale}  •  ${loop.bars} bars',
                    style: textTheme.bodySmall?.copyWith(color: colors.subtleText),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: onFavorite,
                  child: Icon(
                    loop.isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: AppTheme.iconMd,
                    color: loop.isFavorite ? colors.neonSecondary : colors.subtleText,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  _formatDuration(loop.durationSeconds),
                  style: textTheme.labelSmall?.copyWith(color: colors.subtleText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(double seconds) {
    final s = seconds.round();
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }
}

class _MiniWaveform extends StatelessWidget {
  final int seed;
  final Color color;

  const _MiniWaveform({required this.seed, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        child: CustomPaint(
          painter: _MiniWavePainter(seed: seed, color: color),
        ),
      ),
    );
  }
}

class _MiniWavePainter extends CustomPainter {
  final int seed;
  final Color color;

  const _MiniWavePainter({required this.seed, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = color.withOpacity(0.1);
    canvas.drawRect(Offset.zero & size, bg);

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final rng = Random(seed);
    final bars = 12;
    final barW = size.width / bars;

    for (int i = 0; i < bars; i++) {
      final h = (rng.nextDouble() * 0.8 + 0.1) * size.height;
      final x = i * barW + barW / 2;
      final top = (size.height - h) / 2;
      canvas.drawLine(Offset(x, top), Offset(x, top + h), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MiniWavePainter oldDelegate) =>
      oldDelegate.seed != seed;
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
