import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../core/app_themes.dart';
import '../../main.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressRepositoryProvider);
    final selectedTheme = progress.selectedTheme;
    final skinsUnlocked = progress.skinsUnlocked;

    final bgColor = AppColors.background(context);
    final cardColor = AppColors.surface(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final accent = AppColors.accent(context);

    // Which themes are free by default
    const freeThemes = {
      GameTheme.classic,
      GameTheme.neon,
      GameTheme.retro,
      GameTheme.cyber,
    };

    final ownedCount = GameTheme.values
        .where((t) => freeThemes.contains(t) || skinsUnlocked)
        .length;
    final totalCount = GameTheme.values.length;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // --- Header ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inventory',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$ownedCount of $totalCount skins owned',
                      style: TextStyle(
                        fontSize: 14,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Grid of skins ---
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final theme = GameTheme.values[index];
                    final isFree = freeThemes.contains(theme);
                    final isUnlocked = isFree || skinsUnlocked;
                    final isSelected = selectedTheme == theme;
                    final previewColors = AppThemes.getThemeColors(theme);

                    return GestureDetector(
                      onTap: () {
                        if (isUnlocked) {
                          ref
                              .read(progressRepositoryProvider)
                              .setTheme(theme);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Locked — unlock all skins in Settings',
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected
                              ? Border.all(color: accent, width: 2.5)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cardShadow(context),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(17.5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // --- Preview area ---
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: previewColors.bgGradient,
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: previewColors.surface,
                                        borderRadius:
                                        BorderRadius.circular(14),
                                        border: Border.all(
                                          color: previewColors.arrowColor
                                              .withValues(alpha: 0.5),
                                          width: 2,
                                        ),
                                        boxShadow: previewColors.hasGlow
                                            ? [
                                          BoxShadow(
                                            color: previewColors
                                                .arrowColor
                                                .withValues(alpha: 0.5),
                                            blurRadius: 20,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                            : null,
                                      ),
                                      child: Icon(
                                        Icons.arrow_upward_rounded,
                                        color: previewColors.arrowColor,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // --- Label area ---
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                color: cardColor,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        theme.name[0].toUpperCase() +
                                            theme.name.substring(1),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (!isUnlocked)
                                      Icon(
                                        Icons.lock_rounded,
                                        size: 16,
                                        color: textSecondary,
                                      )
                                    else if (isSelected)
                                      Icon(
                                        Icons.check_circle_rounded,
                                        size: 18,
                                        color: accent,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: GameTheme.values.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }
}