import 'dart:math';
import '../models/level.dart';

class LevelShapeGenerator {
  /// Define which levels are "special" and should keep their original shapes.
  /// Assuming special levels are multiples of 5 (e.g., 20, 25, 30).
  static bool isSpecialLevel(int levelNumber) {
    return levelNumber % 5 == 0;
  }

  /// Generates the shape and mask for a normal level.
  static ({MaskShape shape, Set<String> mask}) generateMask(int levelNumber, int gridSize) {
    // 1. If it's a special level, return Square (or whatever default your special generator uses)
    // Note: If your special levels have their own hardcoded masks, you should skip this generator for them.
    if (isSpecialLevel(levelNumber)) {
      return (
      shape: MaskShape.square,
      mask: _generateSquare(gridSize)
      );
    }

    // 2. Cycle through shapes for normal levels based on the level number
    // Using levelNumber % 6 to cycle through 6 different shapes
    final shapeIndex = levelNumber % 6;

    switch (shapeIndex) {
      case 0:
        return (shape: MaskShape.square, mask: _generateSquare(gridSize));
      case 1:
        return (shape: MaskShape.rectangleHorizontal, mask: _generateRectangleH(gridSize));
      case 2:
        return (shape: MaskShape.rectangleVertical, mask: _generateRectangleV(gridSize));
      case 3:
        return (shape: MaskShape.circle, mask: _generateCircle(gridSize));
      case 4:
        return (shape: MaskShape.pyramid, mask: _generatePyramid(gridSize));
      case 5:
        return (shape: MaskShape.diamond, mask: _generateDiamond(gridSize));
      default:
        return (shape: MaskShape.square, mask: _generateSquare(gridSize));
    }
  }

  // ─── MASK GENERATORS ───

  static Set<String> _generateSquare(int size) {
    return {for (int r = 0; r < size; r++) for (int c = 0; c < size; c++) '$r,$c'};
  }

  static Set<String> _generateRectangleH(int size) {
    final mask = <String>{};
    final height = (size * 0.6).round(); // 60% of the grid height
    final startRow = (size - height) ~/ 2;
    for (int r = startRow; r < startRow + height; r++) {
      for (int c = 0; c < size; c++) {
        mask.add('$r,$c');
      }
    }
    return mask;
  }

  static Set<String> _generateRectangleV(int size) {
    final mask = <String>{};
    final width = (size * 0.6).round(); // 60% of the grid width
    final startCol = (size - width) ~/ 2;
    for (int r = 0; r < size; r++) {
      for (int c = startCol; c < startCol + width; c++) {
        mask.add('$r,$c');
      }
    }
    return mask;
  }

  static Set<String> _generateCircle(int size) {
    final mask = <String>{};
    final center = (size - 1) / 2.0;
    final radius = size / 2.0 - 0.5;
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        final dist = sqrt(pow(r - center, 2) + pow(c - center, 2));
        if (dist <= radius) mask.add('$r,$c');
      }
    }
    return mask;
  }

  static Set<String> _generatePyramid(int size) {
    final mask = <String>{};
    final centerCol = size ~/ 2;
    for (int r = 0; r < size; r++) {
      // Width of the pyramid increases as we go down
      final width = (r * (size / (size - 1))).round();
      for (int c = centerCol - width; c <= centerCol + width; c++) {
        if (c >= 0 && c < size) mask.add('$r,$c');
      }
    }
    return mask;
  }

  static Set<String> _generateDiamond(int size) {
    final mask = <String>{};
    final center = (size - 1) / 2.0;
    final radius = size / 2.0;
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        // Manhattan distance for a diamond shape
        final dist = (r - center).abs() + (c - center).abs();
        if (dist <= radius) mask.add('$r,$c');
      }
    }
    return mask;
  }
}