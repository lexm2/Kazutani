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

  final Map<int, Offset> cellBounds = {};

  List<Cell> cells = List.generate(81, (index) => Cell(index));

  ValueNotifier<Duration> gameTime = ValueNotifier(Duration.zero);

  bool isNoteMode = false;
  bool hasWon = false;

  Set<int> selectedCells = {};
  int score = 0;
  int moveCount = 0;

  bool isDragging = false;

  void selectCell(int position) {
    if (!selectedCells.contains(position)) {
      selectedCells.add(position);
    } else {
      selectedCells.remove(position);
    }

    print(SudokuConstraints.isSafe(cells, position, cells[position].value));

    notifyListeners();
  }

  resetSelection() {
    selectedCells.clear();
    selectedCells.add(-1);
    notifyListeners();
  }

  void selectSingleCell(int position) {
    selectedCells.clear();
    selectedCells.add(position);
    notifyListeners();
  }

  void unselectLastCell() {
    if (selectedCells.isNotEmpty) {
      selectedCells.remove(selectedCells.last);
      notifyListeners();
    }
  }

  void selectGrid(int position) {
    int row = position ~/ 9;
    int col = position % 9;
    int boxRow = (row ~/ 3) * 3;
    int boxCol = (col ~/ 3) * 3;

    clearSelection();

    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        selectedCells.add(r * 9 + c);
      }
    }
    notifyListeners();
  }

  // Add helper methods for selection management
  void clearSelection() {
    selectedCells.clear();
    notifyListeners();
  }

  bool isCellSelected(int position) {
    return selectedCells.contains(position);
  }

  void clearCell() {
    for (int position in selectedCells) {
      if (!cells[position].isOriginal) {
        cells[position].clear();
      }
    }
    notifyListeners();
  }

  void setNumber(int number) {
    if (selectedCells.isEmpty) return;

    if (isNoteMode) {
      for (int cellIndex in selectedCells) {
        cells[cellIndex].toggleNote(number);
      }
    } else {
      int selectedCell = selectedCells.first;
      selectedCells.clear();
      selectedCells.add(selectedCell);
      cells[selectedCell].setNumber(number, isNoteMode, cells, this);
      score++;

      if (SudokuConstraints.isGameComplete(cells)) {
        hasWon = true;
        _handleWin();
      }
    }

    saveGame();
    notifyListeners();
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

  Future<void> startNewGame() async {
    print("new game");
    resetGameData(); // Clear existing data first

    // Generate a new game board
    final newBoard = await _logic.getNewGame();

    for (int i = 0; i < 81; i++) {
      cells[i].value = newBoard[i].value;
      cells[i].isOriginal = newBoard[i].isOriginal;
      cells[i].notes.clear();
    }

    selectedCells.clear();
    selectedCells.add(-1);
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
      resetSelection();
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

  void handleHiddenPairBlock() {
    handleNotes(Constraints.box);
  }

  void handleHiddenPairVertical() {
    handleNotes(Constraints.vertical);
  }

  void handleHiddenPairHorizontal() {
    handleNotes(Constraints.horizontal);
  }

  void handleNotes(Constraints constraint) {}
}
