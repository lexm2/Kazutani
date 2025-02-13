import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../utils/game_serializer.dart';
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
    CREATE TABLE IF NOT EXISTS game_states(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      board TEXT NOT NULL,
      original_positions TEXT NOT NULL,
      notes TEXT NOT NULL,
      move_count INTEGER NOT NULL,
      created_at INTEGER NOT NULL,
      last_played_at INTEGER NOT NULL,
      is_completed BOOLEAN NOT NULL DEFAULT 0
    )
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS settings(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      key TEXT NOT NULL,
      value TEXT NOT NULL
    )
  ''');
  }

  Future<int> saveGameState({
    required List<List<int>> board,
    required List<List<bool>> originalPositions,
    required List<List<Set<int>>> notes,
    required int moveCount,
    bool isCompleted = false,
  }) async {
    final db = await database;
    final serializedState =
        GameSerializer.serializeGameState(board, originalPositions, notes);
    final decodedState = json.decode(serializedState);

    final gameDataObj = GameData(
      board: decodedState['board'],
      originalPositions: decodedState['original'],
      notes: decodedState['notes'],
      moveCount: moveCount,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      lastPlayedAt: DateTime.now().millisecondsSinceEpoch,
      isCompleted: isCompleted,
    );

    return await db.insert('game_states', gameDataObj.toMap());
  }

  Future<GameData?> loadLatestGame() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'game_states',
      orderBy: 'last_played_at DESC',
      limit: 1,
    );

    if (results.isEmpty) return null;
    return GameData.fromMap(results.first);
  }
}
