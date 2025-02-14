import 'package:kazutani/src/game/game_state.dart';

import '../utils/sudoku_constraints.dart';

class Cell {
  int value;
  bool isOriginal;
  Set<int> notes;
  final int position;

  Cell(
    this.position, {
    this.value = 0,
    this.isOriginal = false,
    Set<int>? notes,
  }) : notes = notes ?? {};

  int get row => position ~/ 9;
  int get col => position % 9;
  int get box => (row ~/ 3) * 3 + (col ~/ 3);
  int get boxPosition => (row % 3) * 3 + (col % 3);

  double get rightBorderWidth => (col + 1) % 3 == 0 ? 2.0 : 1.0;
  double get leftBorderWidth => col % 3 == 0 ? 2.0 : 1.0;
  double get topBorderWidth => row % 3 == 0 ? 2.0 : 1.0;
  double get bottomBorderWidth => (row + 1) % 3 == 0 ? 2.0 : 1.0;

  void fillFromBoxNumbers(List<int> numbers) {
    int boxStartRow = (box ~/ 3) * 3;
    int boxStartCol = (box % 3) * 3;
    int boxX = row - boxStartRow;
    int boxY = col - boxStartCol;
    int index = boxX * 3 + boxY;
    value = numbers[index];
  }

  // @returns the net score for the move
  int setNumber(
      int number, bool isNoteMode, List<Cell> cells, GameState gameState) {
    print("isOriginal: $isOriginal");
    if (isOriginal) return 100;

    if (isNoteMode) {
      toggleNote(number);
      return 1;
    }
    var validationResult = SudokuConstraints.validateMove(cells, position, number);
    if (validationResult.isValid) {
      gameState.completeValidMove();
      setValue(number);
    } else if (validationResult.conflicts.isNotEmpty) {
      addNote(number);
      for (var conflict in validationResult.conflicts) {
        if (cells[conflict.position].isOriginal) continue;
        int previousNumber = cells[conflict.position].value;
        cells[conflict.position].clear();
        cells[conflict.position].addNote(previousNumber);
      }
    }

    return 18;
  }

  bool setNumberConstrantsOnly(List<Cell> cells, int number) {
    var validationResult = SudokuConstraints.validateMove(cells, position, number);

    if (validationResult.isValid) {
      setValue(number);
      return true;
    } else {
      return false;
    }
  }

  void keepOnlyNotes(Set<int> notesToKeep) {
    notes.removeWhere((note) => !notesToKeep.contains(note));
  }

  void deleteOnlyNotes(Set<int> notesToDelete) {
    notes.removeWhere((note) => notesToDelete.contains(note));
  }

  void clear() {
    value = 0;
    notes.clear();
  }

  void addNote(int number) {
    notes.add(number);
  }

  void removeNote(int number) {
    notes.remove(number);
  }

  void toggleNote(int number) {
    if (notes.contains(number)) {
      notes.remove(number);
    } else {
      notes.add(number);
    }
  }

  void setValue(int newValue) {
    value = newValue;
    notes.clear();
  }

  void markAsOriginal() {
    isOriginal = true;
  }

  @override
  String toString() =>
      'Cell($position: value=$value, original=$isOriginal, notes=$notes)';
}
