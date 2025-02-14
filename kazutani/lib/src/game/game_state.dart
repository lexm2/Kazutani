import '../database/database_helper.dart';
import '../database/game_data.dart';
import 'package:flutter/material.dart';
import 'package:kazutani/src/app.dart';
import 'game_logic.dart';
import '../utils/sudoku_constraints.dart';
import 'cell.dart';

import 'dart:math' as math;

class GameState extends ChangeNotifier {
  final SudokuLogic _logic = SudokuLogic();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Cell> cells = List.generate(81, (index) => Cell(index));

  ValueNotifier<Duration> gameTime = ValueNotifier(Duration.zero);

  bool isNoteMode = false;
  bool hasWon = false;

  int selectedCell = -1;
  int score = 0;
  int moveCount = 0;

  void selectCell(int position) {
    selectedCell = position;
    print(SudokuConstraints.isSafe(
        cells, selectedCell, cells[selectedCell].value));
    notifyListeners();
  }

  void setNumber(int number) {
    if (selectedCell != -1) {
      cells[selectedCell].setNumber(number, isNoteMode, cells, this);
      score++;

      if (SudokuConstraints.isGameComplete(cells)) {
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
    for (var cell in cells) {
      cell.notes.clear();
    }
    notifyListeners();
  }

  void startNewGame() {
    print("new game");
    resetGameData(); // Clear existing data first

    // Generate a board of just ones
    final newBoard = _logic.generateOptimizedBoard();

    for (int i = 0; i < 81; i++) {
      cells[i].value = newBoard[i].value;
      cells[i].isOriginal = newBoard[i].isOriginal;
      cells[i].notes.clear();
    }

    selectedCell = -1;
    score = 0;
    moveCount = 0;
    hasWon = false;
    gameTime.value = Duration.zero;

    saveGame(); // Save the initial state
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
    return SudokuConstraints.findMatchingNotes(cells, position, constraint);
  }

  List<(List<int>, Set<int>)> findNakedSets(
      int position, Constraints constraint) {
    return SudokuConstraints.findNakedCells(cells, position, constraint);
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

  void handleHiddenPairs(Constraints constraint) {
    if (selectedCell != -1) {
      var hiddenPairs = findHiddenPairs(selectedCell, constraint);
      for (var (position, notes) in hiddenPairs) {
        cells[position].keepOnlyNotes(notes);
      }
      notifyListeners();
    }
  }

  void handleNakedSets(Constraints constraint) {
    if (selectedCell != -1) {
      var nakedSets = findNakedSets(selectedCell, constraint);
      for (var (positions, notes) in nakedSets) {
        var cellsToCheck =
            SudokuConstraints.getCellsToCheck(cells, selectedCell, constraint);
        for (var checkPos in cellsToCheck) {
          if (!positions.contains(checkPos)) {
            cells[checkPos].deleteOnlyNotes(notes);
          }
        }
      }
      notifyListeners();
    }
  }

  void handleHiddenPairBlock() {
    handleHiddenPairs(Constraints.box);
  }

  void handleHiddenPairVertical() {
    handleHiddenPairs(Constraints.vertical);
  }

  void handleHiddenPairHorizontal() {
    handleHiddenPairs(Constraints.horizontal);
  }
}
