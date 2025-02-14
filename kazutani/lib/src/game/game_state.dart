import '../database/database_helper.dart';
import '../database/game_data.dart';
import 'package:flutter/material.dart';
import 'package:kazutani/src/app.dart';
import 'game_logic.dart';
import '../utils/sudoku_constraints.dart';
import 'cell.dart';

class GameState extends ChangeNotifier {
  final SudokuLogic _logic = SudokuLogic();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  static final List<Cell> cells = List.generate(81, (index) => Cell(index));

  ValueNotifier<Duration> gameTime = ValueNotifier(Duration.zero);

  bool isNoteMode = false;
  bool hasWon = false;

  int selectedCell = -1;
  int score = 0;
  int moveCount = 0;

  void selectCell(int position) {
    selectedCell = position;
    notifyListeners();
  }

  void setNumber(int number) {
    if (selectedCell != -1) {
      cells[selectedCell].setNumber(number, isNoteMode, cells, this);
      score++;

      if (SudokuConstraints.isGameComplete()) {
        hasWon = true;
        _handleWin();
      }

      saveGame();
      notifyListeners();
    }
  }

  void clearCell() {
    if (selectedCell != -1 && !cells[selectedCell].isOriginal) {
      cells[selectedCell].clear();
      notifyListeners();
    }
  }

  void _handleWin() {
    MyApp.navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => AlertDialog(
          title: Text('Congratulations!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('You completed the puzzle!'),
              Text('Moves: $moveCount'),
              SizedBox(height: 16),
              Text(
                  'Game Time: ${gameTime.value.inMinutes}:${(gameTime.value.inSeconds.remainder(60)).toString().padLeft(2, '0')}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                resetGame();
              },
              child: Text('Play Again'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('Main Menu'),
            ),
          ],
        ),
      ),
    );
  }

  void resetGame() {
    startNewGame();
    moveCount = 0;
    hasWon = false;
    gameTime.value = Duration.zero;
    for (var cell in cells) {
      cell.notes.clear();
    }
    notifyListeners();
  }

  void startNewGame() {
    _logic.generatePuzzle();
    notifyListeners();
  }

  void toggleNoteMode() {
    isNoteMode = !isNoteMode;
    notifyListeners();
  }

  void saveGame() {
    _dbHelper.saveGameState(
      cells: cells,
      moveCount: moveCount,
    );
  }

  Future<void> loadLastGame() async {
    final GameData? gameData = await _dbHelper.loadLatestGame();
    if (gameData != null) {
      for (int i = 0; i < 81; i++) {
        cells[i].value = gameData.cells[i].value;
        cells[i].isOriginal = gameData.cells[i].isOriginal;
        cells[i].notes = gameData.cells[i].notes;
      }

      moveCount = gameData.moveCount;
      selectedCell = -1;
      hasWon = false;

      notifyListeners();
    }
  }

  List<(int, Set<int>)> findHiddenPairs(int position, Constraints constraint) {
    return SudokuConstraints.findHiddenPairs(position, constraint);
  }

  resetGameData() {
    for (var cell in cells) {
      cell.value = 0;
      cell.notes.clear();
    }
  }

  completeValidMove() {
    moveCount++;
    notifyListeners();
  }
}
