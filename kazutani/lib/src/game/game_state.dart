import 'package:flutter/material.dart';
import 'package:kazutani/src/app.dart';
import 'game_logic.dart';

class GameState extends ChangeNotifier {
  final SudokuLogic _logic = SudokuLogic();
  List<List<int>> board = List.generate(9, (_) => List.filled(9, 0));
  List<List<bool>> isOriginal = List.generate(9, (_) => List.filled(9, false));
  int selectedRow = -1;
  int selectedCol = -1;
  String difficulty = 'easy';
  bool hasWon = false;
  int moveCount = 0;
  ValueNotifier<Duration> gameTime = ValueNotifier(Duration.zero);

  void selectCell(int row, int col) {
    selectedRow = row;
    selectedCol = col;
    notifyListeners();
  }

  void setNumber(int number) {
    if (selectedRow != -1 &&
        selectedCol != -1 &&
        !isOriginal[selectedRow][selectedCol]) {
      if (_logic.validateMove(board, selectedRow, selectedCol, number)) {
        board[selectedRow][selectedCol] = number;
        moveCount++;

        if (_logic.isGameComplete(board)) {
          hasWon = true;
          _handleWin();
        }
        notifyListeners();
      }
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
              Text('Difficulty: ${difficulty.toUpperCase()}'),
              SizedBox(height: 16),
              Text('Game Time: ${gameTime.value.inMinutes}:${(gameTime.value.inSeconds.remainder(60)).toString().padLeft(2, '0')}'),
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
  }

  void startNewGame() {
    board = _logic.generatePuzzle(difficulty);
    _setOriginalNumbers();
    notifyListeners();
  }

  void _setOriginalNumbers() {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        isOriginal[i][j] = board[i][j] != 0;
      }
    }
  }

  void setDifficulty(String newDifficulty) {
    difficulty = newDifficulty;
    startNewGame();
  }

  void completeGameTest() {
    print('Starting game completion test');

    bool solveSudoku(List<List<int>> board) {
      int row = -1;
      int col = -1;
      bool isEmpty = false;

      // Find empty cell
      for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
          if (board[i][j] == 0) {
            row = i;
            col = j;
            isEmpty = true;
            break;
          }
        }
        if (isEmpty) break;
      }

      // No empty cell found - puzzle solved
      if (!isEmpty) return true;

      // Try digits 1-9
      for (int num = 1; num <= 9; num++) {
        if (_logic.validateMove(board, row, col, num)) {
          board[row][col] = num;
          selectedRow = row;
          selectedCol = col;
          print('Placing $num at [$row][$col]');

          if (solveSudoku(board)) return true;

          board[row][col] = 0; // Backtrack
        }
      }
      return false;
    }

    if (solveSudoku(board)) {
      print('Solution found!');
      if (_logic.isGameComplete(board)) {
        hasWon = true;
        _handleWin();
      }
    } else {
      print('No solution exists');
    }

    notifyListeners();
  }
}
