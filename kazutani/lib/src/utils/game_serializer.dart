import 'dart:convert';
import 'dart:typed_data';

class GameSerializer {
  static Map<String, dynamic> serializeGameState(
      List<List<int>> board, List<List<bool>> isOriginal, int moveCount) {
    // Pack board into bytes
    final Uint8List boardBytes = _packBoard(board);
    final Uint8List originalBytes = _packBoolBoard(isOriginal);

    return {
      'board': base64Encode(boardBytes),
      'original': base64Encode(originalBytes),
      'moves': moveCount,
    };
  }

  static Uint8List _packBoard(List<List<int>> board) {
    final bytes = Uint8List((81 * 4) ~/ 8 + 1);
    int byteIndex = 0;
    int bitPosition = 0;

    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        bytes[byteIndex] |= (board[r][c] << bitPosition);
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
    final bytes = Uint8List((81) ~/ 8 + 1);
    int byteIndex = 0;
    int bitPosition = 0;

    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c]) {
          bytes[byteIndex] |= (1 << bitPosition);
        }
        bitPosition++;
        if (bitPosition >= 8) {
          bitPosition = 0;
          byteIndex++;
        }
      }
    }
    return bytes;
  }

  static (List<List<int>>, List<List<bool>>, int) deserializeGameState(
      String serialized) {
    final data = json.decode(serialized);

    final board = _unpackBoard(base64Decode(data['board']));
    final original = _unpackBoolBoard(base64Decode(data['original']));

    return (board, original, data['moves'] as int);
  }

  static List<List<int>> _unpackBoard(Uint8List bytes) {
    final board = List.generate(9, (_) => List.filled(9, 0));
    int byteIndex = 0;
    int bitPosition = 0;

    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        board[r][c] = (bytes[byteIndex] >> bitPosition) & 0xF;
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

    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        board[r][c] = ((bytes[byteIndex] >> bitPosition) & 1) == 1;
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
