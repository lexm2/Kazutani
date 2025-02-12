import 'dart:math';

class SudokuLogic {
  // Generate a valid Sudoku puzzle
  List<List<int>> generatePuzzle(String difficulty) {
    List<List<int>> grid = List.generate(9, (_) => List.filled(9, 0));
    _fillDiagonal(grid);
    _solveSudoku(grid);
    _removeNumbers(grid, difficulty);
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

  void _removeNumbers(List<List<int>> grid, String difficulty) {
    int numbersToRemove = _getDifficultyCount(difficulty);
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

  int _getDifficultyCount(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return 30;
      case 'medium':
        return 40;
      case 'hard':
        return 50;
      default:
        return 30;
    }
  }

  bool validateMove(List<List<int>> grid, int row, int col, int number) {
    // Check if the move is valid according to Sudoku rules
    return _isSafe(grid, row, col, number);
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
