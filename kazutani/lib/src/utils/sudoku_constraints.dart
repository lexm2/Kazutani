import '../game/game_state.dart';
import '../game/cell.dart';

enum Constraints { horizontal, vertical, box }

class ConflictPosition {
  final int position;
  final int number;

  ConflictPosition(this.position, this.number);
}

class ValidationResult {
  final bool isValid;
  final List<ConflictPosition> conflicts;

  ValidationResult(this.isValid, this.conflicts);
}

class SudokuConstraints {
  static List<Cell> get cells => GameState.cells;

  static ValidationResult validateMove(int position, int number) {
    List<ConflictPosition> conflicts = [];
    Cell cell = cells[position];

    // Check row
    for (int i = 0; i < 9; i++) {
      int checkPos = cell.row * 9 + i;
      if (cells[checkPos].value == number) {
        conflicts.add(ConflictPosition(checkPos, number));
      }
    }

    // Check column
    for (int i = 0; i < 9; i++) {
      int checkPos = i * 9 + cell.col;
      if (cells[checkPos].value == number) {
        conflicts.add(ConflictPosition(checkPos, number));
      }
    }

    // Check 3x3 box
    int boxStartRow = (cell.row ~/ 3) * 3;
    int boxStartCol = (cell.col ~/ 3) * 3;
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        int checkPos = (boxStartRow + r) * 9 + (boxStartCol + c);
        if (cells[checkPos].value == number) {
          conflicts.add(ConflictPosition(checkPos, number));
        }
      }
    }

    return ValidationResult(conflicts.isEmpty, conflicts);
  }

  static bool isGameComplete() {
    // Check boxes
    for (int box = 0; box < 9; box++) {
      Set<int> boxNumbers = {};
      int boxStartRow = (box ~/ 3) * 3;
      int boxStartCol = (box % 3) * 3;

      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < 3; c++) {
          int pos = (boxStartRow + r) * 9 + (boxStartCol + c);
          int value = cells[pos].value;
          if (value == 0 || !boxNumbers.add(value)) return false;
        }
      }
    }

    // Check rows
    for (int row = 0; row < 9; row++) {
      Set<int> rowNumbers = {};
      for (int col = 0; col < 9; col++) {
        int value = cells[row * 9 + col].value;
        if (!rowNumbers.add(value)) return false;
      }
    }

    // Check columns
    for (int col = 0; col < 9; col++) {
      Set<int> colNumbers = {};
      for (int row = 0; row < 9; row++) {
        int value = cells[row * 9 + col].value;
        if (!colNumbers.add(value)) return false;
      }
    }

    return true;
  }

  static List<(int, Set<int>)> findHiddenPairs(
      int position, Constraints constraint) {
    List<(int, Set<int>)> hiddenPairs = [];
    Map<Set<int>, List<int>> candidatePositions = {};

    List<int> cellsToCheck = _getCellsToCheck(position, constraint);

    for (var checkPos in cellsToCheck) {
      var currentNotes = cells[checkPos].notes;
      if (currentNotes.length >= 2) {
        for (var i = 2; i <= currentNotes.length; i++) {
          for (var combination in _getCombinations(currentNotes.toList(), i)) {
            var noteSet = Set<int>.from(combination);
            candidatePositions.putIfAbsent(noteSet, () => []);
            candidatePositions[noteSet]!.add(checkPos);
          }
        }
      }
    }

    candidatePositions.forEach((noteSet, positions) {
      if (noteSet.length == 2 && positions.length == 2) {
        bool isHidden = true;
        for (var checkPos in cellsToCheck) {
          if (!positions.contains(checkPos)) {
            var otherNotes = cells[checkPos].notes;
            if (otherNotes.intersection(noteSet).isNotEmpty) {
              isHidden = false;
              break;
            }
          }
        }
        if (isHidden) {
          positions.forEach((pos) => hiddenPairs.add((pos, noteSet)));
        }
      }
    });

    return hiddenPairs;
  }

  static List<int> _getCellsToCheck(int position, Constraints constraint) {
    Cell cell = cells[position];
    return switch (constraint) {
      Constraints.horizontal => List.generate(9, (col) => cell.row * 9 + col),
      Constraints.vertical => List.generate(9, (row) => row * 9 + cell.col),
      Constraints.box => () {
          int boxStartRow = (cell.row ~/ 3) * 3;
          int boxStartCol = (cell.col ~/ 3) * 3;
          return [
            for (int r = 0; r < 3; r++)
              for (int c = 0; c < 3; c++)
                (boxStartRow + r) * 9 + (boxStartCol + c)
          ];
        }()
    };
  }

  static List<List<int>> _getCombinations(List<int> elements, int length) {
    if (length > elements.length) return [];
    if (length == 0) return [[]];
    if (length == elements.length) return [elements];

    List<List<int>> result = [];
    var first = elements.first;
    var rest = elements.sublist(1);

    var combsWithoutFirst = _getCombinations(rest, length);
    var combsWithFirst = _getCombinations(rest, length - 1)
        .map((comb) => [first, ...comb])
        .toList();

    result.addAll(combsWithoutFirst);
    result.addAll(combsWithFirst);
    return result;
  }

  static bool isSafe(int position, int number) {
    Cell cell = cells[position];

    // Check row
    for (int col = 0; col < 9; col++) {
      if (cells[cell.row * 9 + col].value == number) return false;
    }

    // Check column
    for (int row = 0; row < 9; row++) {
      if (cells[row * 9 + cell.col].value == number) return false;
    }

    // Check box
    int boxStartRow = (cell.row ~/ 3) * 3;
    int boxStartCol = (cell.col ~/ 3) * 3;
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        if (cells[(boxStartRow + r) * 9 + (boxStartCol + c)].value == number)
          return false;
      }
    }

    return true;
  }
}
