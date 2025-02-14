import 'dart:math';
import 'game_state.dart';
import '../utils/sudoku_constraints.dart';

class SudokuLogic {
  void generatePuzzle() {
    _fillDiagonal();
    _solveSudoku();
    _removeNumbers();
  }

  void _fillDiagonal() {
    for (int box = 0; box < 9; box += 4) {
      _fillBox(box);
    }
  }

  void _fillBox(int box) {
    var numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    numbers.shuffle();

    for (var cell in GameState.cells) {
      if (cell.box == box) {
        cell.fillFromBoxNumbers(numbers);
      }
    }
  }

  bool _solveSudoku() {
    int position = _findEmptyCell();
    if (position == -1) return true;

    for (int num = 1; num <= 9; num++) {
      if (SudokuConstraints.isSafe(position, num)) {
        GameState.cells[position].setValue(num);
        if (_solveSudoku()) return true;
        GameState.cells[position].clear();
      }
    }
    return false;
  }

  int _findEmptyCell() {
    for (int i = 0; i < GameState.cells.length; i++) {
      if (GameState.cells[i].value == 0) return i;
    }
    return -1;
  }

  void _removeNumbers() {
    int numbersToRemove = 30;
    Random random = Random();

    while (numbersToRemove > 0) {
      int position = random.nextInt(81);
      if (GameState.cells[position].value != 0) {
        GameState.cells[position].clear();
        numbersToRemove--;
      }
    }

    for (var cell in GameState.cells) {
      if (cell.value != 0) {
        cell.markAsOriginal();
      }
    }
  }
}
