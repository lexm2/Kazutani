import '../database/database_helper.dart';
import '../database/game_data.dart';
import '../utils/game_serializer.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kazutani/src/app.dart';
import 'game_logic.dart';

class GameState extends ChangeNotifier {
  final SudokuLogic _logic = SudokuLogic();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<List<int>> board = List.generate(9, (_) => List.filled(9, 0));
  List<List<bool>> isOriginal = List.generate(9, (_) => List.filled(9, false));
  List<List<Set<int>>> notes =
      List.generate(9, (_) => List.generate(9, (_) => <int>{}));
  bool isNoteMode = false;
  int selectedRow = -1;
  int selectedCol = -1;
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
      if (isNoteMode) {
        if (notes[selectedRow][selectedCol].contains(number)) {
          notes[selectedRow][selectedCol].remove(number);
        } else {
          notes[selectedRow][selectedCol].add(number);
        }
      } else {
        var validationResult = _logic.validateMove(
            board, selectedRow, selectedCol, number, isOriginal);
        if (validationResult.isValid) {
          board[selectedRow][selectedCol] = number;
          notes[selectedRow][selectedCol].clear();
          moveCount++;

          if (_logic.isGameComplete(board)) {
            hasWon = true;
            _handleWin();
          }
        } else if (validationResult.conflicts.isNotEmpty) {
          notes[selectedRow][selectedCol].add(number);
          for (var conflict in validationResult.conflicts) {
            if (conflict.isOriginal) continue;
            int previousNumber = board[conflict.row][conflict.col];
            board[conflict.row][conflict.col] = 0;
            notes[conflict.row][conflict.col].add(previousNumber);
          }
        }
      }
      saveGame();
      notifyListeners();
    }
  }

  void clearCell() {
    if (selectedRow != -1 &&
        selectedCol != -1 &&
        !isOriginal[selectedRow][selectedCol]) {
      board[selectedRow][selectedCol] = 0;
      notes[selectedRow][selectedCol].clear();
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
    notes = List.generate(9, (_) => List.generate(9, (_) => <int>{}));
    notifyListeners();
  }

  void startNewGame() {
    board = _logic.generatePuzzle();
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

  void toggleNoteMode() {
    isNoteMode = !isNoteMode;
    notifyListeners();
  }

  void saveGame() {
    _dbHelper.saveGameState(
      board: board,
      originalPositions: isOriginal,
      moveCount: moveCount,
    );
  }

  Future<void> loadLastGame() async {
    final GameData? gameData = await _dbHelper.loadLatestGame();
    if (gameData != null) {
      String boardStr = gameData.board.replaceAll('[', '').replaceAll(']', '');
      List<String> rows = boardStr.split(',');

      board = List.generate(
          9, (i) => List.generate(9, (j) => int.parse(rows[i * 9 + j].trim())));

      String originalStr =
          gameData.originalPositions.replaceAll('[', '').replaceAll(']', '');
      List<String> originalRows = originalStr.split(',');

      isOriginal = List.generate(
          9,
          (i) => List.generate(
              9, (j) => originalRows[i * 9 + j].trim() == 'true'));

      moveCount = gameData.moveCount;
      selectedRow = -1;
      selectedCol = -1;
      hasWon = false;
      notes = List.generate(9, (_) => List.generate(9, (_) => <int>{}));

      notifyListeners();
    }
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
        if (_logic.validateMove(board, row, col, num, isOriginal).isValid) {
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
