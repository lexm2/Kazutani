import '../database/database_helper.dart';
import '../database/game_data.dart';
import 'package:flutter/material.dart';
import 'package:kazutani/src/app.dart';
import 'game_manager.dart';
import '../utils/sudoku_constraints.dart';
import 'cell.dart';

class BoardState {
  final List<Cell> cells;

  BoardState({required this.cells});

  BoardState copyBoard() {
    var newState = BoardState(
        cells: List.generate(
      81,
      (i) => Cell(
        i,
        value: cells[i].value,
        isOriginal: cells[i].isOriginal,
        notes: Set<int>.from(cells[i].notes),
      ),
    ));
    return newState;
  }
}

class Move {
  final int position;
  final int number;

  Move(this.position, this.number);
}

const Map<String, int> MOVE_SCORES = {
  'valid_placement': 18,
  'note_toggle': 1,
  'invalid_move': -5,
  'original_cell': 0,
};

class GameState extends ChangeNotifier {
  final GameManager _logic = GameManager();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<BoardState> boardHistory = [];
  int currentMoveIndex = -1;
  int score = 0;

  ValueNotifier<Duration> gameTime = ValueNotifier(Duration.zero);
  bool isNoteMode = false;
  bool hasWon = false;
  Set<int> selectedCells = {};
  int moveCount = 0;
  bool isDragging = false;
  final Map<int, Offset> cellBounds = {};

  GameState() {
    _initializeState();
  }

  Future<void> _initializeState() async {
    final GameData? lastGame = await _dbHelper.loadLatestGame();

    if (lastGame != null && !lastGame.isCompleted) {
      BoardState loadedState = BoardState(
        cells: lastGame.cells,
      );

      boardHistory = [loadedState];
      currentMoveIndex = 0;
      moveCount = lastGame.moveCount;
      hasWon = lastGame.isCompleted;
      notifyListeners();
    } else {
      await startNewGame();
    }
  }

  Future<void> solveAsPlayer() async {
    while (!hasWon) {
      BoardState currentState = currentBoard.copyBoard();
      List<Move> nextMoves = [];

      // Find single candidates (cells with only one possible value)
      for (int pos = 0; pos < 81; pos++) {
        if (currentState.cells[pos].value == 0) {
          Set<int> possibilities = {};
          for (int num = 1; num <= 9; num++) {
            if (SudokuConstraints.validateMove(currentState.cells, pos, num)
                .isValid) {
              possibilities.add(num);
            }
          }
          if (possibilities.length == 1) {
            nextMoves.add(Move(pos, possibilities.first));
          }
        }
      }

      // Execute found moves with visual feedback
      for (Move move in nextMoves) {
        selectSingleCell(move.position);
        setNumber(move.number);
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Break if no more obvious moves found
      if (nextMoves.isEmpty) break;
    }
  }

  BoardState get currentBoard {
    if (currentMoveIndex < 0 || boardHistory.isEmpty) {
      return BoardState(
        cells: List.generate(81, (i) => Cell(0)),
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

    BoardState newState = currentBoard.copyBoard();
    if (isNoteMode) {
      for (int cellIndex in selectedCells) {
        if (!newState.cells[cellIndex].isOriginal) {
          if (newState.cells[cellIndex].notes.contains(number)) {
            newState.cells[cellIndex].notes.remove(number);
          } else {
            newState.cells[cellIndex].notes.add(number);
          }
          score += MOVE_SCORES['note_toggle']!;
        }
      }
    } else {
      for (int cellIndex in selectedCells) {
        var validationResult =
            SudokuConstraints.validateMove(newState.cells, cellIndex, number);

        if (validationResult.isValid) {
          newState.cells[cellIndex].value = number;
          newState.cells[cellIndex].notes.clear();
          score += MOVE_SCORES['valid_placement']!;
          completeValidMove();
        } else {
          for (var conflict in validationResult.conflicts) {
            if (!newState.cells[conflict.position].isOriginal) {
              int previousNumber = newState.cells[conflict.position].value;
              newState.cells[conflict.position].value = 0;
              newState.cells[conflict.position].notes.add(previousNumber);
            }
          }
          score += MOVE_SCORES['invalid_move']!;
        }
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

  void setBoardState(BoardState newState) {
    if (currentMoveIndex < boardHistory.length - 1) {
      boardHistory.removeRange(currentMoveIndex + 1, boardHistory.length);
    }

    boardHistory.add(newState);
    currentMoveIndex++;
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
      cells: List.generate(81, (i) => newBoard[i]),
    );

    boardHistory = [initialState];
    currentMoveIndex = 0;
    selectedCells.clear();
    moveCount = 0;
    hasWon = false;
    gameTime.value = Duration.zero;
    score = 0;

    saveGame();
    notifyListeners();
  }

  void resetGame() {
    if (boardHistory.isNotEmpty) {
      boardHistory = [boardHistory[0]];
      currentMoveIndex = 0;
      selectedCells.clear();
      moveCount = 0;
      hasWon = false;
      gameTime.value = Duration.zero;
      score = 0;
      notifyListeners();
    } else {
      startNewGame();
    }
  }

  void toggleNoteMode() {
    isNoteMode = !isNoteMode;
    notifyListeners();
  }

  void saveGame() {
    // Save current state
    _dbHelper.saveGameState(
      boardState: currentBoard,
      moveCount: moveCount,
      isCompleted: hasWon,
    );

    // Save board history
    for (var historicalState in boardHistory) {
      _dbHelper.saveGameState(
          boardState: historicalState,
          moveCount: moveCount,
          isCompleted: false);
    }
  }

  Future<void> loadLastGame() async {
    final GameData? gameData = await _dbHelper.loadLatestGame();
    if (gameData != null) {
      BoardState loadedState = BoardState(
        cells: gameData.cells,
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
              Text('Score: $score'),
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
    BoardState newState = currentBoard.copyBoard();

    for (int position in selectedCells) {
      if (!newState.cells[position].isOriginal) {
        newState.cells[position].value = 0;
        newState.cells[position].notes.clear();
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
