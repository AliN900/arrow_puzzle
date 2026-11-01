import 'board_themes.dart';
import '../../core/app_themes.dart';

class StorePrices {
  StorePrices._();

  /// Coin cost to unlock a board EARLY.
  static const Map<BoardTheme, int> boardPrices = {
    BoardTheme.nebula: 1000,
    BoardTheme.paper: 1500,
    BoardTheme.blueprint: 2000,
    BoardTheme.forest: 3500,
    BoardTheme.sand: 4000,
    BoardTheme.ocean: 5000,
    BoardTheme.cloud: 6500,
    BoardTheme.ember: 7500,
    BoardTheme.mint: 9000,
    BoardTheme.ice: 10000,
    BoardTheme.rose: 12000,
    BoardTheme.cosmic: 15000,
    BoardTheme.lavender: 18000,
    BoardTheme.sky: 22000,
    BoardTheme.geometric: 25000,
    BoardTheme.pearl: 30000,
    BoardTheme.hacker: 40000,
    BoardTheme.honey: 50000,
    BoardTheme.gold: 75000,
  };

  /// Coin cost for arrow skins.
  /// Note: classic (white), neon, retro, and ruby are progression-locked
  /// or free, so they are not in this list.
  static const Map<GameTheme, int> arrowPrices = {

    GameTheme.hacker: 1000,
    GameTheme.blueprint: 2500,
    GameTheme.cyber: 3500,


    GameTheme.forest: 5000,
    GameTheme.aurora: 8000,


    GameTheme.pastel: 12000,
    GameTheme.sunset: 15000,


    GameTheme.rainbowStatic: 20000,
    GameTheme.rainbow: 25000,
  };

  static int? priceForBoard(BoardTheme b) => boardPrices[b];

  static bool isBoardBuyable(BoardTheme b) => boardPrices.containsKey(b);

  static int? priceForArrow(GameTheme theme) => arrowPrices[theme];

  static bool isArrowBuyable(GameTheme theme) => arrowPrices.containsKey(theme);
}