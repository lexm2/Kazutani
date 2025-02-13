class GameData {
  final int? id;
  final String board;
  final String originalPositions;
  final int moveCount;
  final int createdAt;
  final int lastPlayedAt;
  final bool isCompleted;

  GameData({
    this.id,
    required this.board,
    required this.originalPositions,
    required this.moveCount,
    required this.createdAt,
    required this.lastPlayedAt,
    required this.isCompleted,
  });

  factory GameData.fromMap(Map<String, dynamic> map) {
    return GameData(
      id: map['id'] as int?,
      board: map['board'] as String,
      originalPositions: map['original_positions'] as String,
      moveCount: map['move_count'] as int,
      createdAt: map['created_at'] as int,
      lastPlayedAt: map['last_played_at'] as int,
      isCompleted: map['is_completed'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'board': board,
      'original_positions': originalPositions,
      'move_count': moveCount,
      'created_at': createdAt,
      'last_played_at': lastPlayedAt,
      'is_completed': isCompleted ? 1 : 0,
    };
  }
}
