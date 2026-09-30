
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../core/game_mode.dart';
import '../../main.dart';
import '../game/game_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _preWarmLevels();
    });
  }

  void _preWarmLevels() {
    final progress = ref.read(progressRepositoryProvider);
    final levelRepo = ref.read(levelRepositoryProvider);
    final currentLevel = progress.currentLevel;
    for (int i = 0; i < 4; i++) {
      levelRepo.preGenerateAsync(currentLevel + i);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(progressRepositoryProvider);

    // Theme-aware colors
    final bgColor = AppColors.background(context);
    final cardColor = AppColors.surface(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final accent = AppColors.accent(context);

    // Real data from repository
    final int currentLevel = progress.currentLevel;
    final int highestLevel = progress.highestUnlockedLevel;
    final bool skinsUnlocked = progress.skinsUnlocked;
    final int starsEarned = List.generate(currentLevel, (i) => i + 1)
        .fold(0, (sum, l) => sum + progress.getStarsForLevel(l));

    // Icon accent colors (fixed palette, theme-independent)
    const coinYellow = Color(0xFFFFD54F);
    const trophyRed = Color(0xFFFF5A5F);
    const inventoryGreen = Color(0xFF00C853);
    const dailyBlue = Color(0xFF448AFF);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Top Header ---
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'P',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Player',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          'Level $currentLevel · $starsEarned stars',
                          style: TextStyle(
                            fontSize: 13,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --- Continue Level Card ---
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
                    Text(
                      'CONTINUE',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textSecondary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Level $currentLevel',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isNavigating
                            ? null
                            : () async {
                          if (!mounted) return;
                          setState(() => _isNavigating = true);
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GameScreen(
                                level: currentLevel,
                                gameMode: GameMode.classic,
                              ),
                            ),
                          );
                          if (mounted) {
                            setState(() => _isNavigating = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow_rounded, size: 28),
                            SizedBox(width: 8),
                            Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 18,
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

              const SizedBox(height: 16),

              // --- Progress Card ---
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
                        Icon(Icons.trending_up_rounded, color: accent, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Progress',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'You\'ve unlocked $highestLevel level${highestLevel == 1 ? '' : 's'} and earned $starsEarned star${starsEarned == 1 ? '' : 's'} so far.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // --- 2x2 Grid Section ---
              Row(
                children: [
                  Expanded(
                    child: _buildGridCard(
                      context: context,
                      title: 'Daily',
                      subtitle: 'Ready to play',
                      icon: Icons.calendar_today_rounded,
                      iconColor: dailyBlue,
                      hasBadge: true,
                      badgeColor: trophyRed,
                      onTap: () {
                        ref.read(currentTabProvider.notifier).state = 1;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildGridCard(
                      context: context,
                      title: 'Stars',
                      subtitle: '$starsEarned earned',
                      icon: Icons.star_rounded,
                      iconColor: coinYellow,
                      badgeColor: trophyRed,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Star stats coming soon'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildGridCard(
                      context: context,
                      title: 'Inventory',
                      subtitle: skinsUnlocked
                          ? 'All skins unlocked'
                          : '4 skins owned',
                      icon: Icons.grid_view_rounded,
                      iconColor: inventoryGreen,
                      badgeColor: trophyRed,
                      onTap: () {
                        ref.read(currentTabProvider.notifier).state = 2;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildGridCard(
                      context: context,
                      title: 'Trophies',
                      subtitle: '$starsEarned of ${highestLevel * 3}',
                      icon: Icons.emoji_events_rounded,
                      iconColor: trophyRed,
                      badgeColor: trophyRed,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Trophies coming soon'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
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

  Widget _buildGridCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color badgeColor,
    required VoidCallback onTap,
    bool hasBadge = false,
  }) {
    final cardColor = AppColors.surface(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: iconColor, size: 28),
                if (hasBadge)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: badgeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}