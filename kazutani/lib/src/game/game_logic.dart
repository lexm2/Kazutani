import 'dart:math';

class ConflictPosition {
  final int row;
  final int col;
  final int number;
  final bool isOriginal;

  ConflictPosition(this.row, this.col, this.number, this.isOriginal);
}

class ValidationResult {
  final bool isValid;
  final List<ConflictPosition> conflicts;

  ValidationResult(this.isValid, this.conflicts);
}

class SudokuLogic {
  // Generate a valid Sudoku puzzle
  List<List<int>> generatePuzzle() {
    List<List<int>> grid = List.generate(9, (_) => List.filled(9, 0));
    _fillDiagonal(grid);
    _solveSudoku(grid);
    _removeNumbers(grid);
    return grid;
  }

  void _fillDiagonal(List<List<int>> grid) {
    for (int i = 0; i < 9; i += 3) {
      _fillBox(grid, i, i);
    }
  }

  void _fillBox(List<List<int>> grid, int row, int col) {
    var numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    numbers.shuffle();
    int index = 0;

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        grid[row + i][col + j] = numbers[index++];
      }
    }
  }

  bool _solveSudoku(List<List<int>> grid) {
    int row = 0, col = 0;
    bool isEmpty = false;

    for (row = 0; row < 9; row++) {
      for (col = 0; col < 9; col++) {
        if (grid[row][col] == 0) {
          isEmpty = true;
          break;
        }
      }
      if (isEmpty) break;
    }

    if (!isEmpty) return true;

    for (int num = 1; num <= 9; num++) {
      if (_isSafe(grid, row, col, num)) {
        grid[row][col] = num;
        if (_solveSudoku(grid)) return true;
        grid[row][col] = 0;
      }
    }
    return false;
  }

  bool _isSafe(List<List<int>> grid, int row, int col, int num) {
    // Check row
    for (int x = 0; x < 9; x++) {
      if (grid[row][x] == num) return false;
    }

    // Check column
    for (int x = 0; x < 9; x++) {
      if (grid[x][col] == num) return false;
    }

    // Check 3x3 box
    int startRow = row - row % 3, startCol = col - col % 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (grid[i + startRow][j + startCol] == num) return false;
      }
    }

    return true;
  }

  void _removeNumbers(List<List<int>> grid) {
    // TODO: Implement removal logic
    int numbersToRemove = 30;
    Random random = Random();

    while (numbersToRemove > 0) {
      int row = random.nextInt(9);
      int col = random.nextInt(9);

      if (grid[row][col] != 0) {
        grid[row][col] = 0;
        numbersToRemove--;
      }
    }
  }

  ValidationResult validateMove(List<List<int>> board, int row, int col,
      int number, List<List<bool>> isOriginal) {
    List<ConflictPosition> conflicts = [];

    // Check row
    for (int c = 0; c < 9; c++) {
      if (board[row][c] == number) {
        conflicts.add(ConflictPosition(row, c, number, isOriginal[row][c]));
      }
    }

    // Check column
    for (int r = 0; r < 9; r++) {
      if (board[r][col] == number) {
        conflicts.add(ConflictPosition(r, col, number, isOriginal[r][col]));
      }
    }

    // Check 3x3 box
    int boxRow = row - row % 3;
    int boxCol = col - col % 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if (board[r][c] == number) {
          conflicts.add(ConflictPosition(r, c, number, isOriginal[r][c]));
        }
      }
    }

    return ValidationResult(conflicts.isEmpty, conflicts);
  }

  bool isGameComplete(List<List<int>> grid) {
    // Check 3x3 boxes
    for (int boxRow = 0; boxRow < 9; boxRow += 3) {
      for (int boxCol = 0; boxCol < 9; boxCol += 3) {
        Set<int> boxNumbers = {};
        for (int i = 0; i < 3; i++) {
          for (int j = 0; j < 3; j++) {
            int num = grid[boxRow + i][boxCol + j];
            if (num == 0) {
              print('Empty cell in box at [${boxRow + i}][${boxCol + j}]');
              return false;
            }
            if (!boxNumbers.add(num)) {
              print(
                  'Duplicate number $num in 3x3 box starting at [$boxRow][$boxCol]');
              return false;
            }
          }
        }
      }
    }

    // Check columns
    for (int col = 0; col < 9; col++) {
      Set<int> colNumbers = {};
      for (int row = 0; row < 9; row++) {
        int num = grid[row][col];
        if (!colNumbers.add(num)) {
          print('Duplicate number $num in column $col');
          return false;
        }
      }
    }

    // Check rows
    for (int row = 0; row < 9; row++) {
      Set<int> rowNumbers = {};
      for (int col = 0; col < 9; col++) {
        int num = grid[row][col];
        if (!rowNumbers.add(num)) {
          print('Duplicate number $num in row $row');
          return false;
        }
      }
    }

    return true;
  }
}
