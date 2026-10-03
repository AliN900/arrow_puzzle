import 'dart:math';

enum ArrowDirection {
  up,
  down,
  left,
  right;

  List<int> get delta {
    switch (this) {
      case ArrowDirection.up:    return [-1, 0];
      case ArrowDirection.down:  return [1, 0];
      case ArrowDirection.left:  return [0, -1];
      case ArrowDirection.right: return [0, 1];
    }
  }

  double get rotationRadians {
    switch (this) {
      case ArrowDirection.right: return 0;
      case ArrowDirection.down:  return pi / 2;
      case ArrowDirection.left:  return pi;
      case ArrowDirection.up:    return -pi / 2;
    }
  }

  ArrowDirection get opposite {
    switch (this) {
      case ArrowDirection.up:    return ArrowDirection.down;
      case ArrowDirection.down:  return ArrowDirection.up;
      case ArrowDirection.left:  return ArrowDirection.right;
      case ArrowDirection.right: return ArrowDirection.left;
    }
  }

  ArrowDirection get turnRight {
    switch (this) {
      case ArrowDirection.up:    return ArrowDirection.right;
      case ArrowDirection.right: return ArrowDirection.down;
      case ArrowDirection.down:  return ArrowDirection.left;
      case ArrowDirection.left:  return ArrowDirection.up;
    }
  }

  ArrowDirection get turnLeft {
    switch (this) {
      case ArrowDirection.up:    return ArrowDirection.left;
      case ArrowDirection.left:  return ArrowDirection.down;
      case ArrowDirection.down:  return ArrowDirection.right;
      case ArrowDirection.right: return ArrowDirection.up;
    }
  }
}

enum ArrowState {
  idle,
  sliding,
  blocked,
}

/// NEW — distinguishes normal arrows from bomb arrows.
enum ArrowType {
  normal,
  bomb,
}

class ArrowModel {
  final String id;
  int row;
  int col;
  ArrowDirection direction;
  ArrowState state;

  /// NEW — 'normal' by default; 'bomb' when paired with a rock.
  final ArrowType type;

  /// NEW — for bomb arrows, the id of the RockModel this arrow destroys.
  /// Null for normal arrows.
  final String? targetRockId;

  final List<List<int>> path;

  ArrowModel({
    required this.id,
    required this.row,
    required this.col,
    required this.direction,
    this.state = ArrowState.idle,
    this.type = ArrowType.normal,
    this.targetRockId,
    List<List<int>>? path,
  }) : path = path ?? [[row, col]];

  ArrowModel copyWith({
    String? id,
    int? row,
    int? col,
    ArrowDirection? direction,
    ArrowState? state,
    ArrowType? type,
    String? targetRockId,
    List<List<int>>? path,
  }) {
    return ArrowModel(
      id: id ?? this.id,
      row: row ?? this.row,
      col: col ?? this.col,
      direction: direction ?? this.direction,
      state: state ?? this.state,
      type: type ?? this.type,
      targetRockId: targetRockId ?? this.targetRockId,
      path: path ?? this.path,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'row': row,
    'col': col,
    'direction': direction.index,
    'state': state.index,
    'type': type.index,
    'targetRockId': targetRockId,
    'path': path,
  };

  factory ArrowModel.fromJson(Map<String, dynamic> json) => ArrowModel(
    id: json['id'] as String,
    row: json['row'] as int,
    col: json['col'] as int,
    direction: ArrowDirection.values[json['direction'] as int],
    state: ArrowState.values[json['state'] as int],
    type: json['type'] != null
        ? ArrowType.values[json['type'] as int]
        : ArrowType.normal,
    targetRockId: json['targetRockId'] as String?,
    path: (json['path'] as List<dynamic>?)
        ?.map((e) => (e as List<dynamic>).map((x) => x as int).toList())
        .toList(),
  );

  @override
  String toString() =>
      'Arrow($id @ [$row,$col] ${direction.name}, type: ${type.name}, path: $path)';
}