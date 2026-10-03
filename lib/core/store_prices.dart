import 'board_themes.dart';

class StorePrices {
  StorePrices._();

  /// Coin cost to unlock a board EARLY.
  /// Boards still unlock for free by reaching their unlockLevel.
  static const Map<BoardTheme, int> boardPrices = {
    BoardTheme.nebula: 200,
    BoardTheme.paper: 250,
    BoardTheme.blueprint: 300,
    BoardTheme.forest: 500,
    BoardTheme.sand: 550,
    BoardTheme.ocean: 600,
    BoardTheme.cloud: 700,
    BoardTheme.ember: 750,
    BoardTheme.mint: 850,
    BoardTheme.ice: 900,
    BoardTheme.rose: 950,
    BoardTheme.cosmic: 1200,
    BoardTheme.lavender: 1300,
    BoardTheme.sky: 1700,
    BoardTheme.geometric: 1800,
    BoardTheme.pearl: 2200,
    BoardTheme.hacker: 2500,
    BoardTheme.honey: 2800,
    BoardTheme.gold: 3000,
    // minimal is free — not in map
  };

  /// Coin cost for arrow skins. All non-free arrow skins cost the same.
  static const int arrowPrice = 400;

  static int? priceForBoard(BoardTheme b) => boardPrices[b];

  static bool isBoardBuyable(BoardTheme b) => boardPrices.containsKey(b);
}