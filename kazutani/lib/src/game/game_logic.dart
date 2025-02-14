import '../utils/sudoku_constraints.dart';
import 'cell.dart';
import 'dart:math';

class SudokuLogic {
  int _solutionCount = 0;
  // Generates a complete valid Sudoku board using optimized backtracking
  List<Cell> generateOptimizedBoard() {
    print('Starting board generation...');
    List<Cell> cells = List.generate(81, (index) => Cell(index));

    if (_fillBoardOptimized(cells)) {
      print('Board generation complete. Validating...');
      if (_validateFullBoard(cells)) {
        print('Board validation successful!');
        return generatePuzzle(cells);
      }
      print('Board validation failed!');
    }

    throw Exception('Failed to generate valid board');
  }

  bool _fillBoardOptimized(List<Cell> cells) {
    var nextPos = _findMostConstrainedCell(cells);
    print('Next position to fill: $nextPos');

    if (nextPos == -1) {
      print('No more empty cells - board complete');
      return true;
    }

    List<int> numbers = _getLeastConstrainingValues(cells, nextPos);
    print('Available numbers for position $nextPos: $numbers');

    for (int num in numbers) {
      print('Attempting to place $num at position $nextPos');

      if (cells[nextPos].setNumberConstrantsOnly(cells, num)) {
        print('Successfully placed $num at position $nextPos');
        cells[nextPos].markAsOriginal();

        if (_fillBoardOptimized(cells)) {
          return true;
        }

        print('Backtracking: removing $num from position $nextPos');
        cells[nextPos].clear();
      }
    }
    return false;
  }

  bool _validateFullBoard(List<Cell> cells) {
    // Check each cell has a value
    for (int i = 0; i < 81; i++) {
      if (cells[i].value == 0) {
        print('Cell $i is empty!');
        return false;
      }
    }

    // Check each row
    for (int row = 0; row < 9; row++) {
      Set<int> numbers = {};
      for (int col = 0; col < 9; col++) {
        int value = cells[row * 9 + col].value;
        if (!numbers.add(value)) {
          print('Row $row has duplicate value $value');
          return false;
        }
      }
    }

    // Check each column
    for (int col = 0; col < 9; col++) {
      Set<int> numbers = {};
      for (int row = 0; row < 9; row++) {
        int value = cells[row * 9 + col].value;
        if (!numbers.add(value)) {
          print('Column $col has duplicate value $value');
          return false;
        }
      }
    }

    // Check each 3x3 box
    for (int box = 0; box < 9; box++) {
      Set<int> numbers = {};
      int boxRow = (box ~/ 3) * 3;
      int boxCol = (box % 3) * 3;

      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          int value = cells[(boxRow + i) * 9 + (boxCol + j)].value;
          if (!numbers.add(value)) {
            print('Box $box has duplicate value $value');
            return false;
          }
        }
      }
    }

    return true;
  }

  int _findMostConstrainedCell(List<Cell> cells) {
    int minPossibilities = 10;
    int bestPos = -1;

    for (int i = 0; i < 81; i++) {
      if (cells[i].value != 0) continue;

      int count = _countPossibleValues(cells, i);
      if (count < minPossibilities) {
        minPossibilities = count;
        bestPos = i;
      }
    }
    return bestPos;
  }

  int _countPossibleValues(List<Cell> cells, int position) {
    int count = 0;
    for (int num = 1; num <= 9; num++) {
      if (SudokuConstraints.isSafe(cells, position, num)) {
        count++;
      }
    }
    return count;
  }

  List<int> _getLeastConstrainingValues(List<Cell> cells, int position) {
    var numbers = List<int>.filled(9, 0);
    var count = 0;

    for (int num = 1; num <= 9; num++) {
      // Check both position safety and current board state
      if (SudokuConstraints.isSafe(cells, position, num) &&
          _isValidPlacement(cells, position, num)) {
        numbers[count] = num;
        count++;
      }
    }

    numbers = numbers.sublist(0, count);
    numbers.shuffle();
    return numbers;
  }

  bool _isValidPlacement(List<Cell> cells, int position, int number) {
    int row = position ~/ 9;
    int col = position % 9;

    // Check row
    for (int i = 0; i < 9; i++) {
      if (cells[row * 9 + i].value == number) return false;
    }

    // Check column
    for (int i = 0; i < 9; i++) {
      if (cells[i * 9 + col].value == number) return false;
    }

    // Check 3x3 box
    int boxRow = row - (row % 3);
    int boxCol = col - (col % 3);
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (cells[(boxRow + i) * 9 + (boxCol + j)].value == number)
          return false;
      }
    }

    return true;
  }

  List<Cell> generatePuzzle(List<Cell> cells) {
    List<Cell> puzzleCells = List.generate(
        81, (i) => Cell(i, value: cells[i].value, isOriginal: true));

    for (int pos = 0; pos < 81; pos++) {
      int temp = puzzleCells[pos].value;
      puzzleCells[pos].clear();
      puzzleCells[pos].isOriginal = false;

      List<Cell> tempCells =
          List.generate(81, (i) => Cell(i, value: puzzleCells[i].value));

      _solutionCount = 0;
      _countSolutions(tempCells);

      if (_solutionCount > 1) {
        puzzleCells[pos].setValue(temp);
        puzzleCells[pos].markAsOriginal();
      }
    }

    return puzzleCells;
  }

  void _countSolutions(List<Cell> cells) {
    if (_solutionCount > 1) return;

    int pos = _findEmptyCell(cells);
    if (pos == -1) {
      _solutionCount++;
      return;
    }

    for (int num = 1; num <= 9; num++) {
      if (SudokuConstraints.validateMove(cells, pos, num).isValid) {
        cells[pos].setValue(num);
        _countSolutions(cells);
        cells[pos].clear();
      }
    }
  }

  int _findEmptyCell(List<Cell> cells) {
    for (int i = 0; i < 81; i++) {
      if (cells[i].value == 0) return i;
    }
    return -1;
  }
}
