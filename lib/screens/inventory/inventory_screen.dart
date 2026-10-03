import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../core/app_themes.dart';
import '../../core/board_themes.dart';
import '../../core/items.dart';
import '../../core/store_prices.dart';
import '../../main.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final bgColor = AppColors.background(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final accent = AppColors.accent(context);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                children: [
                  Text(
                    'Inventory',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _tabButton('Arrows', 0, accent, textPrimary, textSecondary),
                    _tabButton('Boards', 1, accent, textPrimary, textSecondary),
                    _tabButton('Items', 2, accent, textPrimary, textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _tab == 0
                  ? const _ArrowsGrid()
                  : _tab == 1
                  ? const _BoardsGrid()
                  : const _ItemsGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(
      String label,
      int index,
      Color accent,
      Color textPrimary,
      Color textSecondary,
      ) {
    final selected = _tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? accent : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: selected ? Colors.white : textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// ARROWS
// ══════════════════════════════════════════════════════════════

class _ArrowsGrid extends ConsumerWidget {
  const _ArrowsGrid();

  Future<void> _buyArrow(
      BuildContext context,
      WidgetRef ref,
      GameTheme theme,
      ) async {
    final progress = ref.read(progressRepositoryProvider);
    final coinsRepo = ref.read(coinsRepositoryProvider);
    final price = StorePrices.arrowPrice;

    if (progress.isArrowPurchased(theme)) return;
    if (coinsRepo.coins < price) {
      _showNotEnough(context, price, coinsRepo.coins);
      return;
    }

    final confirmed = await _showConfirmDialog(
      context,
      title: theme.name[0].toUpperCase() + theme.name.substring(1),
      price: price,
    );
    if (confirmed != true) return;

    final success = await coinsRepo.spendCoins(price);
    if (!success) return;
    await progress.markArrowPurchased(theme);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressRepositoryProvider);
    final selectedTheme = progress.selectedTheme;
    final cardColor = AppColors.surface(context);
    final accent = AppColors.accent(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    const coinYellow = Color(0xFFFFD54F);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final theme = GameTheme.values[index];
              final isUnlocked = progress.isArrowUnlocked(theme);
              final isSelected = selectedTheme == theme;
              final previewColors = AppThemes.getThemeColors(theme);
              final price = StorePrices.arrowPrice;

              return GestureDetector(
                onTap: () {
                  if (isUnlocked) {
                    ref.read(progressRepositoryProvider).setTheme(theme);
                  } else {
                    _buyArrow(context, ref, theme);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? Border.all(color: accent, width: 2.5)
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(17.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  gradient: previewColors.bgGradient,
                                ),
                              ),
                              Center(
                                child: Icon(
                                  Icons.arrow_upward_rounded,
                                  color: previewColors.arrowColor,
                                  size: 36,
                                ),
                              ),
                              if (!isUnlocked)
                                Container(
                                  color: Colors.black.withValues(alpha: 0.55),
                                  child: const Center(
                                    child: Icon(
                                      Icons.lock_rounded,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          color: cardColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      theme.name[0].toUpperCase() +
                                          theme.name.substring(1),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isUnlocked && isSelected)
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 18,
                                      color: accent,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              if (isUnlocked)
                                Text(
                                  isSelected ? 'Equipped' : 'Tap to equip',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSelected ? accent : textSecondary,
                                  ),
                                )
                              else
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.circle,
                                      color: coinYellow,
                                      size: 10,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$price',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: coinYellow,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }, childCount: GameTheme.values.length),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// BOARDS
// ══════════════════════════════════════════════════════════════

class _BoardsGrid extends ConsumerWidget {
  const _BoardsGrid();

  Future<void> _buyBoard(
      BuildContext context,
      WidgetRef ref,
      BoardTheme board,
      ) async {
    final progress = ref.read(progressRepositoryProvider);
    final coinsRepo = ref.read(coinsRepositoryProvider);
    final price = StorePrices.priceForBoard(board) ?? 0;

    if (price == 0) return;
    if (progress.isBoardPurchased(board)) return;
    if (coinsRepo.coins < price) {
      _showNotEnough(context, price, coinsRepo.coins);
      return;
    }

    final confirmed = await _showConfirmDialog(
      context,
      title: board.name[0].toUpperCase() + board.name.substring(1),
      price: price,
    );
    if (confirmed != true) return;

    final success = await coinsRepo.spendCoins(price);
    if (!success) return;
    await progress.markBoardPurchased(board);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressRepositoryProvider);
    final selectedBoard = progress.selectedBoard;
    final cardColor = AppColors.surface(context);
    final accent = AppColors.accent(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    const coinYellow = Color(0xFFFFD54F);

    final boards = BoardThemes.all;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final board = boards[index];
              final colors = BoardThemes.get(board);
              final isUnlocked = progress.isBoardUnlocked(board);
              final isSelected = selectedBoard == board;
              final price = StorePrices.priceForBoard(board);

              return GestureDetector(
                onTap: () {
                  if (isUnlocked) {
                    ref.read(progressRepositoryProvider).setBoard(board);
                    ref.read(progressRepositoryProvider).markBoardViewed(board);
                  } else if (price != null) {
                    _buyBoard(context, ref, board);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Reach level ${colors.unlockLevel} to unlock',
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
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(17.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  gradient: colors.gradient,
                                ),
                              ),
                              CustomPaint(
                                painter: _BoardPatternPainter(
                                  pattern: colors.pattern,
                                  color: colors.patternColor,
                                  seed: board.index * 9137 + 42,
                                ),
                              ),
                              Center(
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: colors.dotColor.withValues(alpha: 0.7),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              if (!isUnlocked)
                                Container(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  child: const Center(
                                    child: Icon(
                                      Icons.lock_rounded,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                  ),
                                ),
                              if (progress.isBoardNew(board))
                                Positioned(
                                  top: 8,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF3B30),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          color: cardColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      board.name[0].toUpperCase() +
                                          board.name.substring(1),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isUnlocked && isSelected)
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 18,
                                      color: accent,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              if (isUnlocked)
                                Text(
                                  isSelected ? 'Equipped' : 'Tap to equip',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSelected ? accent : textSecondary,
                                  ),
                                )
                              else if (price != null)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.circle,
                                      color: coinYellow,
                                      size: 10,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$price',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: coinYellow,
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Text(
                                  'Lv ${colors.unlockLevel}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }, childCount: boards.length),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// ITEMS (placeholder)
// ══════════════════════════════════════════════════════════════

class _ItemsGrid extends ConsumerWidget {
  const _ItemsGrid();

  Future<void> _buyItem(
      BuildContext context,
      WidgetRef ref,
      ItemType item,
      ItemBundle bundle,
      ) async {
    final coinsRepo = ref.read(coinsRepositoryProvider);
    final price = bundle.price;

    if (coinsRepo.coins < price) {
      final missing = price - coinsRepo.coins;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Need $missing more coins'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final confirmed = await _showBuyConfirm(context, item, bundle);
    if (confirmed != true) return;

    final success = await coinsRepo.spendCoins(price);
    if (success) {
      await coinsRepo.addItem(item, count: bundle.count);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coinsRepo = ref.watch(coinsRepositoryProvider);
    final cardColor = AppColors.surface(context);
    final accent = AppColors.accent(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    const coinYellow = Color(0xFFFFD54F);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: ItemType.values.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = ItemType.values[index];
        final owned = coinsRepo.getItemCount(item);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(item.icon, color: accent, size: 30),
              ),
              const SizedBox(width: 14),

              // Name + description + owned
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.displayName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: textPrimary,
                          ),
                        ),
                        if (owned > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '×$owned',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: accent,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                  ],
                ),
              ),

              // Buy button
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ...ItemPricing.bundlesFor(item).map((bundle) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: ElevatedButton(
                        onPressed: () => _buyItem(context, ref, item, bundle),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: coinYellow,
                          foregroundColor: const Color(0xFF5D4A1A),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '×${bundle.count}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.circle, color: Color(0xFF5D4A1A), size: 8),
                            const SizedBox(width: 3),
                            Text(
                              '${bundle.price}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool?> _showBuyConfirm(
      BuildContext context,
      ItemType item,
      ItemBundle bundle,
      ) {
    final accent = AppColors.accent(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    const coinYellow = Color(0xFFFFD54F);

    return showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, color: accent, size: 48),
              const SizedBox(height: 12),
              Text(
                'Buy ${item.displayName}?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: textSecondary),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.circle, color: coinYellow, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    '${bundle.price} coins',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: coinYellow,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Buy',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SHARED HELPERS
// ══════════════════════════════════════════════════════════════

Future<bool?> _showConfirmDialog(
    BuildContext context, {
      required String title,
      required int price,
    }) {
  final accent = AppColors.accent(context);
  final textPrimary = AppColors.textPrimary(context);
  final textSecondary = AppColors.textSecondary(context);
  const coinYellow = Color(0xFFFFD54F);

  return showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: AppColors.surface(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Unlock $title?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, color: coinYellow, size: 14),
                const SizedBox(width: 6),
                Text(
                  '$price coins',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: coinYellow,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Buy',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void _showNotEnough(BuildContext context, int price, int balance) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Need ${price - balance} more coins',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}

class _BoardPatternPainter extends CustomPainter {
  final BoardPattern pattern;
  final Color color;
  final int seed;

  _BoardPatternPainter({
    required this.pattern,
    required this.color,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    BoardThemes.paintPattern(
      canvas,
      Rect.fromLTWH(0, 0, size.width, size.height),
      pattern,
      color,
      seed,
    );
  }

  @override
  bool shouldRepaint(covariant _BoardPatternPainter old) =>
      old.pattern != pattern || old.color != color || old.seed != seed;
}