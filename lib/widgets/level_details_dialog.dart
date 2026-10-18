import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_colors.dart';
import '../core/audio_haptic_helper.dart';
import '../data/models/level.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import 'pop_dialog.dart';

class LevelDetailsDialog extends ConsumerStatefulWidget {
  final int levelNumber;
  const LevelDetailsDialog({super.key, required this.levelNumber});

  /// Show the dialog. Resolves to `true` if the player tapped Start.
  static Future<bool?> show(BuildContext context, int levelNumber) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => LevelDetailsDialog(levelNumber: levelNumber),
    );
  }

  @override
  ConsumerState<LevelDetailsDialog> createState() =>
      _LevelDetailsDialogState();
}

class _LevelDetailsDialogState extends ConsumerState<LevelDetailsDialog> {
  LevelModel? _level;
  bool _loading = true;
  bool _failed = false;

  static bool _isTimedLevel(int n) => n >= 30 && n % 5 == 0;

  static int _timeForLevel(int n, int arrowCount) {
    final progress = (n / 500.0).clamp(0.0, 1.0);
    final base = 18.0 - progress * 10.0;
    final perArrow = 3.5 - progress * 1.5;
    return (base + perArrow * arrowCount).round();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(levelRepositoryProvider);
    try {
      final level = repo.isCached(widget.levelNumber)
          ? repo.getLevel(widget.levelNumber)
          : await repo.getLevelAsync(widget.levelNumber);
      if (!mounted) return;
      setState(() {
        _level = level;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final progress = ref.watch(progressRepositoryProvider);

    final surface = AppColors.surface(context);
    final accent = AppColors.accent(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);

    final level = _level;
    final isCompleted = progress.isLevelCompleted(widget.levelNumber);
    final stars = progress.getStarsForLevel(widget.levelNumber);
    final isTimed = _isTimedLevel(widget.levelNumber);
    final timeSeconds = (level != null && isTimed)
        ? _timeForLevel(widget.levelNumber, level.arrows.length)
        : 0;
    final mineCount = level?.rocks.length ?? 0;
    final gridSize = level?.gridSize ?? 0;

    return PopDialog(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: accent.withValues(alpha: 0.35),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.18),
              blurRadius: 32,
            ),
          ],
        ),
        child: _loading
            ? const SizedBox(
          height: 220,
          child: Center(child: CircularProgressIndicator()),
        )
            : _failed
            ? _buildError(textPrimary, textSecondary)
            : Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header icon ──
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.flag_rounded,
                  color: accent,
                  size: 34,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Title ──
            Text(
              strings.levelDetailsTitle(widget.levelNumber),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: textPrimary,
              ),
            ),

            // ── Stars or "not played" ──
            if (isCompleted) ...[
              const SizedBox(height: 8),
              Center(child: _StarsRow(stars: stars)),
              const SizedBox(height: 4),
              Text(
                strings.levelDetailsCompleted,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
            ] else ...[
              const SizedBox(height: 4),
              Text(
                strings.levelDetailsNotPlayed,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: textSecondary,
                ),
              ),
            ],

            const SizedBox(height: 20),

            // ── Feature chips ──
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _FeatureChip(
                  icon: Icons.grid_on_rounded,
                  label: '$gridSize×$gridSize',
                  color: accent,
                  textPrimary: textPrimary,
                ),
                if (isTimed)
                  _FeatureChip(
                    icon: Icons.timer_rounded,
                    label: '${timeSeconds}s',
                    color: const Color(0xFFFF9800),
                    textPrimary: textPrimary,
                  ),
                if (mineCount > 0)
                  _FeatureChip(
                    icon: Icons.dangerous_rounded,
                    label: '$mineCount',
                    color: const Color(0xFFE53935),
                    textPrimary: textPrimary,
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Start button (matches win/lose dialog style) ──
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  AudioHapticHelper.playClick();
                  Navigator.pop(context, true);
                },
                icon: const Icon(Icons.play_arrow_rounded, size: 26),
                label: Text(
                  strings.levelDetailsStart,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () {
                AudioHapticHelper.playClick();
                Navigator.pop(context, false);
              },
              child: Text(
                strings.profileCancel,
                style: TextStyle(
                  color: textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(Color textPrimary, Color textSecondary) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: textSecondary, size: 40),
            const SizedBox(height: 12),
            Text(
              'Failed to load level',
              style: TextStyle(color: textPrimary, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textPrimary;

  const _FeatureChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StarsRow extends StatelessWidget {
  final int stars;
  const _StarsRow({required this.stars});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
            (i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(
            i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
            color: i < stars
                ? const Color(0xFFFFC107)
                : Colors.grey.withValues(alpha: 0.35),
            size: 30,
          ),
        ),
      ),
    );
  }
}