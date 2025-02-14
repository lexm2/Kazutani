import 'dart:convert';
import 'dart:typed_data';
import '../game/cell.dart';

class GameSerializer {
  // TODO: we are not using this for simplicity right now because of database changes being constant, add this back in when the final databse structure has been decided

  static String serializeGameState(List<Cell> cells) {
    final valuesBytes = _packValues(cells);
    final originalBytes = _packOriginal(cells);
    final notesBytes = _packNotes(cells);

    return json.encode({
      'values': base64Encode(valuesBytes),
      'original': base64Encode(originalBytes),
      'notes': base64Encode(notesBytes),
    });
  }

  static Uint8List _packValues(List<Cell> cells) {
    final bytes = Uint8List(41); // 81 cells, 4 bits per value = 41 bytes
    int byteIndex = 0;
    int bitPosition = 0;

    for (var cell in cells) {
      bytes[byteIndex] |= (cell.value << bitPosition);
      bitPosition += 4;
      if (bitPosition >= 8) {
        bitPosition = 0;
        byteIndex++;
      }
    }
    return bytes;
  }

  static Uint8List _packOriginal(List<Cell> cells) {
    final bytes = Uint8List(11); // 81 cells, 1 bit per bool = 11 bytes
    int byteIndex = 0;
    int bitPosition = 0;

    for (var cell in cells) {
      if (cell.isOriginal) bytes[byteIndex] |= (1 << bitPosition);
      bitPosition++;
      if (bitPosition >= 8) {
        bitPosition = 0;
        byteIndex++;
      }
    }
    return bytes;
  }

  static Uint8List _packNotes(List<Cell> cells) {
    final bytes =
        Uint8List(102); // 81 cells, 9 possible notes per cell = 102 bytes
    int byteIndex = 0;
    int bitPosition = 0;

    for (var cell in cells) {
      for (int i = 1; i <= 9; i++) {
        if (cell.notes.contains(i)) bytes[byteIndex] |= (1 << bitPosition);
        bitPosition++;
        if (bitPosition >= 8) {
          bitPosition = 0;
          byteIndex++;
        }
      }
    }
    return bytes;
  }

  static List<Cell> deserializeGameState(String serialized) {
    final data = json.decode(serialized);
    final values = _unpackValues(base64Decode(data['values']));
    final original = _unpackOriginal(base64Decode(data['original']));
    final notes = _unpackNotes(base64Decode(data['notes']));

    return List.generate(
        81,
        (i) => Cell(
              i,
              value: values[i],
              isOriginal: original[i],
              notes: notes[i],
            ));
  }

  static List<int> _unpackValues(Uint8List bytes) {
    final values = List.filled(81, 0);
    int byteIndex = 0;
    int bitPosition = 0;

    for (int i = 0; i < 81; i++) {
      values[i] = (bytes[byteIndex] >> bitPosition) & 0xF;
      bitPosition += 4;
      if (bitPosition >= 8) {
        bitPosition = 0;
        byteIndex++;
      }
    }
    return values;
  }

  static List<bool> _unpackOriginal(Uint8List bytes) {
    final original = List.filled(81, false);
    int byteIndex = 0;
    int bitPosition = 0;

    for (int i = 0; i < 81; i++) {
      original[i] = ((bytes[byteIndex] >> bitPosition) & 1) == 1;
      bitPosition++;
      if (bitPosition >= 8) {
        bitPosition = 0;
        byteIndex++;
      }
    }
    return original;
  }

  static List<Set<int>> _unpackNotes(Uint8List bytes) {
    final notes = List.generate(81, (_) => <int>{});
    int byteIndex = 0;
    int bitPosition = 0;

    for (int i = 0; i < 81; i++) {
      for (int n = 1; n <= 9; n++) {
        if (((bytes[byteIndex] >> bitPosition) & 1) == 1) {
          notes[i].add(n);
        }
        bitPosition++;
        if (bitPosition >= 8) {
          bitPosition = 0;
          byteIndex++;
        }
      }
    }
    return notes;
  }
}
