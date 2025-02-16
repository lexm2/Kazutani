import '../database/database_helper.dart';
import '../database/game_data.dart';
import 'package:flutter/material.dart';
import 'package:kazutani/src/app.dart';
import 'cell.dart';
import 'game_manager.dart';
import '../utils/sudoku_constraints.dart';

class BoardState {
  final List<int> values;
  final List<bool> isOriginal;
  final List<Set<int>> notes;

  BoardState({
    required this.values,
    required this.isOriginal,
    required this.notes,
  });

  BoardState.copy(BoardState other)
      : values = List.from(other.values),
        isOriginal = List.from(other.isOriginal),
        notes = List.from(other.notes.map((s) => Set<int>.from(s)));
}

class GameState extends ChangeNotifier {
  final GameManager _logic = GameManager();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<BoardState> boardHistory = [];
  int currentMoveIndex = -1;

  ValueNotifier<Duration> gameTime = ValueNotifier(Duration.zero);
  bool isNoteMode = false;
  bool hasWon = false;
  Set<int> selectedCells = {};
  int moveCount = 0;
  bool isDragging = false;
  final Map<int, Offset> cellBounds = {};

  BoardState get currentBoard {
    if (currentMoveIndex < 0 || boardHistory.isEmpty) {
      return BoardState(
        values: List.filled(81, 0),
        isOriginal: List.filled(81, false),
        notes: List.generate(81, (_) => <int>{}),
      );
    }
    return boardHistory[currentMoveIndex];
  }

  void selectCell(int position) {
    if (!selectedCells.contains(position)) {
      selectedCells.add(position);
    } else {
      selectedCells.remove(position);
    }
    notifyListeners();
  }

  void selectSingleCell(int position) {
    selectedCells.clear();
    selectedCells.add(position);
    notifyListeners();
  }

  void selectGrid(int position) {
    int row = position ~/ 9;
    int col = position % 9;
    int boxRow = (row ~/ 3) * 3;
    int boxCol = (col ~/ 3) * 3;

    selectedCells.clear();
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        selectedCells.add(r * 9 + c);
      }
    }
    notifyListeners();
  }

  void clearSelection() {
    selectedCells.clear();
    notifyListeners();
  }

  void setNumber(int number) {
    if (selectedCells.isEmpty) return;

    BoardState newState = BoardState.copy(currentBoard);

    if (isNoteMode) {
      for (int cellIndex in selectedCells) {
        if (!newState.isOriginal[cellIndex]) {
          if (newState.notes[cellIndex].contains(number)) {
            newState.notes[cellIndex].remove(number);
          } else {
            newState.notes[cellIndex].add(number);
          }
        }
      }
    } else {
      int selectedCell = selectedCells.first;
      if (!newState.isOriginal[selectedCell]) {
        newState.values[selectedCell] = number;
        newState.notes[selectedCell].clear();
      }
    }

    if (currentMoveIndex < boardHistory.length - 1) {
      boardHistory.removeRange(currentMoveIndex + 1, boardHistory.length);
    }

    boardHistory.add(newState);
    currentMoveIndex++;
    moveCount++;

    if (SudokuConstraints.isGameComplete(
        newState.values.map((value) => Cell(value)).toList())) {
      hasWon = true;
      _handleWin();
    }

    saveGame();
    notifyListeners();
  }

  void undo() {
    if (currentMoveIndex > 0) {
      currentMoveIndex--;
      notifyListeners();
    }
  }

  void redo() {
    if (currentMoveIndex < boardHistory.length - 1) {
      currentMoveIndex++;
      notifyListeners();
    }
  }

  Future<void> startNewGame() async {
    final newBoard = await _logic.getNewGame();

    BoardState initialState = BoardState(
      values: List.generate(81, (i) => newBoard[i].value),
      isOriginal: List.generate(81, (i) => newBoard[i].isOriginal),
      notes: List.generate(81, (i) => <int>{}),
    );

    boardHistory = [initialState];
    currentMoveIndex = 0;
    selectedCells.clear();
    moveCount = 0;
    hasWon = false;
    gameTime.value = Duration.zero;

    saveGame();
    notifyListeners();
  }

  void toggleNoteMode() {
    isNoteMode = !isNoteMode;
    notifyListeners();
  }

  void saveGame() {
    _dbHelper.saveGameState(
      boardState: currentBoard,
      moveCount: moveCount,
      isCompleted: hasWon,
    );
  }

  Future<void> loadLastGame() async {
    final GameData? gameData = await _dbHelper.loadLatestGame();
    if (gameData != null) {
      BoardState loadedState = BoardState(
        values: List.generate(81, (i) => gameData.cells[i].value),
        isOriginal: List.generate(81, (i) => gameData.cells[i].isOriginal),
        notes: List.generate(81, (i) => gameData.cells[i].notes),
      );

      boardHistory = [loadedState];
      currentMoveIndex = 0;
      moveCount = gameData.moveCount;
      selectedCells.clear();
      hasWon = gameData.isCompleted;

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
                startNewGame();
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

  void clearCell() {
    BoardState newState = BoardState.copy(currentBoard);

    for (int position in selectedCells) {
      if (!newState.isOriginal[position]) {
        newState.values[position] = 0;
        newState.notes[position].clear();
      }
    }

    if (currentMoveIndex < boardHistory.length - 1) {
      boardHistory.removeRange(currentMoveIndex + 1, boardHistory.length);
    }

    boardHistory.add(newState);
    currentMoveIndex++;
    moveCount++;

    saveGame();
    notifyListeners();
  }

  void resetGame() {
    if (boardHistory.isNotEmpty) {
      boardHistory = [boardHistory[0]]; // Keep only initial state
      currentMoveIndex = 0;
      selectedCells.clear();
      moveCount = 0;
      hasWon = false;
      gameTime.value = Duration.zero;
      startNewGame();
      notifyListeners();
    } else {
      startNewGame();
    }
  }

  void completeValidMove() {
    moveCount++;
    notifyListeners();
  }

  void startDragging() {
    isDragging = true;
    notifyListeners();
  }

  void stopDragging() {
    isDragging = false;
    notifyListeners();
  }

  void updateCellBound(int index, Offset position) {
    cellBounds[index] = position;
  }
}
