import 'arrow.dart';

enum OrphanDotType { up, down, left, right, neutral }

class OrphanDot {
  final int row, col;
  final OrphanDotType type;
  const OrphanDot({required this.row, required this.col, required this.type});

  String get key => '$row,$col';

  Map<String, dynamic> toJson() => {
    'row': row,
    'col': col,
    'type': type.index,
  };

  factory OrphanDot.fromJson(Map<String, dynamic> json) => OrphanDot(
    row: json['row'] as int,
    col: json['col'] as int,
    type: OrphanDotType.values[json['type'] as int],
  );
}

/// NEW — a permanent wall that can only be destroyed by its paired bomb arrow.
class RockModel {
  final String id;
  final int row;
  final int col;

  const RockModel({
    required this.id,
    required this.row,
    required this.col,
  });

  String get key => '$row,$col';

  RockModel copyWith({String? id, int? row, int? col}) => RockModel(
    id: id ?? this.id,
    row: row ?? this.row,
    col: col ?? this.col,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'row': row,
    'col': col,
  };

  factory RockModel.fromJson(Map<String, dynamic> json) => RockModel(
    id: json['id'] as String,
    row: json['row'] as int,
    col: json['col'] as int,
  );

  @override
  String toString() => 'Rock($id @ [$row,$col])';
}

enum MaskShape {
  square,
  circle,
  heart,
  star,
  diamond,
  hexagon,
  blob,
  cat,
  dog,
  frog,
  fox,
  tiger,
  panda,
  fish,
  bird,
  butterfly,
  guitar,
  tree,
  house,
  crown,
}

class LevelModel {
  static const int currentVersion = 5;

  final int levelNumber;
  final int gridSize;
  final List<ArrowModel> arrows;

  /// NEW — rocks currently on the board.
  final List<RockModel> rocks;

  final MaskShape maskShape;
  final Set<String> mask;
  final List<OrphanDot> orphanDots;
  final int version;

  LevelModel({
    required this.levelNumber,
    required this.gridSize,
    required this.arrows,
    this.rocks = const [],
    this.maskShape = MaskShape.square,
    this.mask = const {},
    this.orphanDots = const [],
    this.version = currentVersion,
  });

  LevelModel copyWith({
    int? levelNumber,
    int? gridSize,
    List<ArrowModel>? arrows,
    List<RockModel>? rocks,
    MaskShape? maskShape,
    Set<String>? mask,
    List<OrphanDot>? orphanDots,
    int? version,
  }) => LevelModel(
    levelNumber: levelNumber ?? this.levelNumber,
    gridSize: gridSize ?? this.gridSize,
    arrows: arrows ?? this.arrows,
    rocks: rocks ?? this.rocks,
    maskShape: maskShape ?? this.maskShape,
    mask: mask ?? this.mask,
    orphanDots: orphanDots ?? this.orphanDots,
    version: version ?? this.version,
  );

  Map<String, dynamic> toJson() => {
    'levelNumber': levelNumber,
    'gridSize': gridSize,
    'arrows': arrows.map((a) => a.toJson()).toList(),
    'rocks': rocks.map((r) => r.toJson()).toList(),
    'maskShape': maskShape.index,
    'mask': mask.toList(),
    'orphanDots': orphanDots.map((d) => d.toJson()).toList(),
    'version': version,
  };

  factory LevelModel.fromJson(Map<String, dynamic> json) => LevelModel(
    levelNumber: json['levelNumber'] as int,
    gridSize: json['gridSize'] as int,
    arrows: (json['arrows'] as List)
        .map((a) => ArrowModel.fromJson(a as Map<String, dynamic>))
        .toList(),
    rocks: json['rocks'] != null
        ? (json['rocks'] as List)
        .map((r) => RockModel.fromJson(r as Map<String, dynamic>))
        .toList()
        : const [],
    maskShape: json['maskShape'] != null
        ? MaskShape.values[(json['maskShape'] as int)
        .clamp(0, MaskShape.values.length - 1)]
        : MaskShape.square,
    mask: json['mask'] != null
        ? Set<String>.from((json['mask'] as List).cast<String>())
        : const {},
    orphanDots: json['orphanDots'] != null
        ? (json['orphanDots'] as List)
        .map((d) => OrphanDot.fromJson(d as Map<String, dynamic>))
        .toList()
        : const [],
    version: json['version'] as int? ?? 1,
  );
}