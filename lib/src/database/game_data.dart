import 'dart:convert';
import '../game/cell.dart';

class GameData {
  final int? id;
  final List<Cell> cells;
  final int moveCount;
  final int createdAt;
  final int lastPlayedAt;
  final bool isCompleted;

  GameData({
    this.id,
    required this.cells,
    required this.moveCount,
    required this.createdAt,
    required this.lastPlayedAt,
    required this.isCompleted,
  });

  factory GameData.fromMap(Map<String, dynamic> map) {
    List<dynamic> cellsData = [];
    if (map['cells'] != null) {
      cellsData = json.decode(map['cells']);
    }

    List<Cell> cells = List.generate(81, (index) {
      if (cellsData.isEmpty) {
        return Cell(index);
      }
      var cellData = cellsData[index];
      return Cell(
        index,
        value: cellData['value'],
        isOriginal: cellData['isOriginal'],
        notes: Set<int>.from(cellData['notes']),
      );
    });

    return GameData(
      id: map['id'] as int?,
      cells: cells,
      moveCount: map['move_count'] as int? ?? 0,
      createdAt:
          map['created_at'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      lastPlayedAt: map['last_played_at'] as int? ??
          DateTime.now().millisecondsSinceEpoch,
      isCompleted: map['is_completed'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    List<Map<String, dynamic>> cellsData = cells
        .map((cell) => {
              'value': cell.value,
              'isOriginal': cell.isOriginal,
              'notes': cell.notes.toList(),
            })
        .toList();

    return {
      'id': id,
      'cells': json.encode(cellsData),
      'move_count': moveCount,
      'created_at': createdAt,
      'last_played_at': lastPlayedAt,
      'is_completed': isCompleted ? 1 : 0,
    };
  }
}
