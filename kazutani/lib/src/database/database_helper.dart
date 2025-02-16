import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../game/cell.dart';
import '../game/game_state.dart';
import 'game_data.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'kazutani.db');

    // if (await databaseExists(path)) {
    //   await deleteDatabase(path);
    //   print('Database deleted');
    // }

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onOpen: (db) async {
        var tables = await db.query('sqlite_master',
            where: 'type = ? AND name = ?',
            whereArgs: ['table', 'game_states']);

        if (tables.isEmpty) {
          await _onCreate(db, 1);
        }
      },
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE game_states(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      board_data TEXT NOT NULL,
      move_count INTEGER NOT NULL,
      created_at INTEGER NOT NULL,
      last_played_at INTEGER NOT NULL,
      is_completed INTEGER NOT NULL DEFAULT 0
    )
  ''');

    await db.execute('''
    CREATE TABLE settings(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      key TEXT NOT NULL,
      value TEXT NOT NULL
    )
  ''');
  }

  Future<int> saveGameState({
    required BoardState boardState,
    required int moveCount,
    bool isCompleted = false,
  }) async {
    final db = await database;

    return await db.insert('game_states', {
      'board_data': json.encode({
        'values': boardState.values,
        'isOriginal': boardState.isOriginal,
        'notes': boardState.notes.map((notes) => notes.toList()).toList(),
      }),
      'move_count': moveCount,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'last_played_at': DateTime.now().millisecondsSinceEpoch,
      'is_completed': isCompleted ? 1 : 0,
    });
  }

  Future<GameData?> loadLatestGame() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'game_states',
      orderBy: 'last_played_at DESC',
      limit: 1,
    );

    if (results.isEmpty || results.first['board_data'] == null) return null;

    final data = results.first;
    final boardData = json.decode(data['board_data'] as String);

    List<Cell> cells = List.generate(81, (i) {
      return Cell(
        i,
        value: boardData['values'][i],
        isOriginal: boardData['isOriginal'][i],
        notes: Set<int>.from(boardData['notes'][i]),
      );
    });

    return GameData(
      id: data['id'],
      cells: cells,
      moveCount: data['move_count'],
      createdAt: data['created_at'],
      lastPlayedAt: data['last_played_at'],
      isCompleted: data['is_completed'] == 1,
    );
  }
}
