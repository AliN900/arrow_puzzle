import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../core/game_mode.dart';
import '../../main.dart';
import '../game/game_screen.dart';

class DailyScreen extends ConsumerWidget {
  const DailyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Placeholder daily data — wire to real logic later
    const int streak = 0;
    const bool claimedToday = false;
    const int bestStreak = 0;
    const int totalDays = 0;

    final bgColor = AppColors.background(context);
    final cardColor = AppColors.surface(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final accent = AppColors.accent(context);

    const accentGreen = Color(0xFF00C853);
    const accentOrange = Color(0xFFFF9800);

    // Build the current week (Mon–Sun)
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekDays = List.generate(7, (i) => monday.add(Duration(days: i)));

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Daily',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Come back every day for a new puzzle.',
                style: TextStyle(fontSize: 14, color: textSecondary),
              ),

              const SizedBox(height: 24),

              // --- Streak Card ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow(context),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: accentOrange.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: accentOrange,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current streak',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$streak days',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- Week Strip ---
              Text(
                'THIS WEEK',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow(context),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: weekDays.map((day) {
                    final isToday = day.day == now.day &&
                        day.month == now.month &&
                        day.year == now.year;
                    // No fake completion — all days start empty
                    const isDone = false;

                    return Column(
                      children: [
                        Text(
                          ['M', 'T', 'W', 'T', 'F', 'S', 'S'][day.weekday - 1],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isToday ? accent : textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isToday
                                ? accent
                                : isDone
                                ? accentGreen.withValues(alpha: 0.15)
                                : bgColor,
                            shape: BoxShape.circle,
                            border: isToday
                                ? null
                                : Border.all(
                              color: AppColors.divider(context),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: isDone && !isToday
                                ? const Icon(
                              Icons.check_rounded,
                              color: accentGreen,
                              size: 18,
                            )
                                : Text(
                              '${day.day}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isToday
                                    ? Colors.white
                                    : textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // --- Today's Challenge Card ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow(context),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'TODAY',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: accent,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFFFD54F), size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '+50 pts',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Today's Puzzle",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'A special daily challenge to keep your streak alive.',
                      style: TextStyle(fontSize: 14, color: textSecondary),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: claimedToday
                            ? null
                            : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const GameScreen(
                                level: 1,
                                gameMode: GameMode.classic,
                                isRandom: true,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                          accent.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              claimedToday
                                  ? Icons.check_circle_rounded
                                  : Icons.play_arrow_rounded,
                              size: 26,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              claimedToday ? 'Completed' : 'Play Now',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- Stats Row ---
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context: context,
                      icon: Icons.emoji_events_rounded,
                      iconColor: accentOrange,
                      label: 'Best streak',
                      value: '$bestStreak',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      context: context,
                      icon: Icons.calendar_month_rounded,
                      iconColor: accent,
                      label: 'Total days',
                      value: '$totalDays',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    final cardColor = AppColors.surface(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow(context),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 26),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: textSecondary),
          ),
        ],
      ),
    );
  }
}