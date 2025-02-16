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
  static ValidationResult validateMove(
      List<Cell> cells, int position, int number) {
    List<ConflictPosition> conflicts = [];
    int row = position ~/ 9;
    int col = position % 9;

    // Check row
    for (int i = 0; i < 9; i++) {
      int checkPos = row * 9 + i;
      if (cells[checkPos].value == number) {
        conflicts.add(ConflictPosition(checkPos, number));
      }
    }

    // Check column
    for (int i = 0; i < 9; i++) {
      int checkPos = i * 9 + col;
      if (cells[checkPos].value == number) {
        conflicts.add(ConflictPosition(checkPos, number));
      }
    }

    // Check 3x3 box
    int boxRow = row - (row % 3);
    int boxCol = col - (col % 3);
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        int checkPos = (boxRow + i) * 9 + (boxCol + j);
        if (cells[checkPos].value == number) {
          conflicts.add(ConflictPosition(checkPos, number));
        }
      }
    }

    return ValidationResult(conflicts.isEmpty, conflicts);
  }

  static bool isGameComplete(List<Cell> cells) {
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

  static List<(int, Set<int>)> findMatchingNotes(
      List<Cell> cells, int position, Constraints constraint) {
    List<(int, Set<int>)> matchingCells = [];
    Set<int> selectedNotes = cells[position].notes;
    List<int> cellsToCheck = getCellsToCheck(cells, position, constraint);

    for (var checkPos in cellsToCheck) {
      if (checkPos == position) continue;
      var currentNotes = cells[checkPos].notes;
      var matchingNotes = currentNotes.intersection(selectedNotes);
      if (matchingNotes.isNotEmpty) {
        matchingCells.add((checkPos, matchingNotes));
      }
    }

    return matchingCells;
  }

  static List<(List<int>, Set<int>)> findNakedCells(
      List<Cell> cells, int position, Constraints constraint) {
    List<(List<int>, Set<int>)> nakedGroups = [];
    List<int> cellsToCheck = getCellsToCheck(cells, position, constraint);

    // Group cells by their exact note sets
    Map<Set<int>, List<int>> noteGroups = {};

    for (var checkPos in cellsToCheck) {
      var currentNotes = cells[checkPos].notes;
      if (currentNotes.length >= 2) {
        var noteSet = currentNotes.toSet();
        noteGroups.putIfAbsent(noteSet, () => []).add(checkPos);
      }
    }

    // Find groups where number of positions equals number of notes
    noteGroups.forEach((notes, positions) {
      if (positions.length == notes.length) {
        nakedGroups.add((positions, notes));
      }
    });

    return nakedGroups;
  }

  static List<int> getCellsToCheck(
      List<Cell> cells, int position, Constraints constraint) {
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

  static bool isSafe(List<Cell> cells, int position, int number) {
    ValidationResult result = validateMove(cells, position, number);
    return result.isValid;
  }
}
