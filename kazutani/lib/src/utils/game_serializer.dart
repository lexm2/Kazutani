import 'dart:convert';
import 'dart:typed_data';

class GameSerializer {
  static String serializeGameState(List<List<int>> board,
      List<List<bool>> isOriginal, List<List<Set<int>>> notes) {
    final boardBytes = _packBoard(board);
    final originalBytes = _packBoolBoard(isOriginal);
    final notesBytes = _packNotes(notes);

    return json.encode({
      'board': base64Encode(boardBytes),
      'original': base64Encode(originalBytes),
      'notes': base64Encode(notesBytes),
    });
  }

  static Uint8List _packNotes(List<List<Set<int>>> notes) {
    final bytes =
        Uint8List(102); // 9x9 cells, 9 possible notes per cell = 102 bytes
    int byteIndex = 0;
    int bitPosition = 0;

    for (var row in notes) {
      for (var cell in row) {
        for (int i = 1; i <= 9; i++) {
          if (cell.contains(i)) bytes[byteIndex] |= (1 << bitPosition);
          bitPosition++;
          if (bitPosition >= 8) {
            bitPosition = 0;
            byteIndex++;
          }
        }
      }
    }
    return bytes;
  }

  static (List<List<int>>, List<List<bool>>, List<List<Set<int>>>)
      deserializeGameState(String serialized) {
    final data = json.decode(serialized);

    final board = _unpackBoard(base64Decode(data['board']));
    final original = _unpackBoolBoard(base64Decode(data['original']));
    final notes = _unpackNotes(base64Decode(data['notes']));

    return (board, original, notes);
  }

  static List<List<Set<int>>> _unpackNotes(Uint8List bytes) {
    final notes = List.generate(9, (_) => List.generate(9, (_) => <int>{}));
    int byteIndex = 0;
    int bitPosition = 0;

    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        for (int n = 1; n <= 9; n++) {
          if (((bytes[byteIndex] >> bitPosition) & 1) == 1) {
            notes[i][j].add(n);
          }
          bitPosition++;
          if (bitPosition >= 8) {
            bitPosition = 0;
            byteIndex++;
          }
        }
      }
    }
    return notes;
  }

  static Uint8List _packBoard(List<List<int>> board) {
    final bytes = Uint8List(41); // 9x9 board, 4 bits per number = 41 bytes
    int byteIndex = 0;
    int bitPosition = 0;

    for (var row in board) {
      for (var value in row) {
        bytes[byteIndex] |= (value << bitPosition);
        bitPosition += 4;
        if (bitPosition >= 8) {
          bitPosition = 0;
          byteIndex++;
        }
      }
    }
    return bytes;
  }

  static Uint8List _packBoolBoard(List<List<bool>> board) {
    final bytes = Uint8List(11); // 9x9 bools, 1 bit per bool = 11 bytes
    int byteIndex = 0;
    int bitPosition = 0;

    for (var row in board) {
      for (var value in row) {
        if (value) bytes[byteIndex] |= (1 << bitPosition);
        bitPosition++;
        if (bitPosition >= 8) {
          bitPosition = 0;
          byteIndex++;
        }
      }
    }
    return bytes;
  }

  static List<List<int>> _unpackBoard(Uint8List bytes) {
    final board = List.generate(9, (_) => List.filled(9, 0));
    int byteIndex = 0;
    int bitPosition = 0;

    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        board[i][j] = (bytes[byteIndex] >> bitPosition) & 0xF;
        bitPosition += 4;
        if (bitPosition >= 8) {
          bitPosition = 0;
          byteIndex++;
        }
      }
    }
    return board;
  }

  static List<List<bool>> _unpackBoolBoard(Uint8List bytes) {
    final board = List.generate(9, (_) => List.filled(9, false));
    int byteIndex = 0;
    int bitPosition = 0;

    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        board[i][j] = ((bytes[byteIndex] >> bitPosition) & 1) == 1;
        bitPosition++;
        if (bitPosition >= 8) {
          bitPosition = 0;
          byteIndex++;
        }
      }
    }
    return board;
  }
}
