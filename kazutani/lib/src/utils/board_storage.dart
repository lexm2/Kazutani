import 'dart:typed_data';

class BoardStorage {
  static Uint8List encodeBoard(List<List<int>> board) {
    final bytes = Uint8List((81 * 4) ~/ 8 + 1);
    int byteIndex = 0;
    int bitPosition = 0;
    
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        int value = board[r][c];
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
  
  static List<List<int>> decodeBoard(Uint8List bytes) {
    final board = List.generate(9, (_) => List.filled(9, 0));
    int byteIndex = 0;
    int bitPosition = 0;
    
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        int value = (bytes[byteIndex] >> bitPosition) & 0xF;
        board[r][c] = value;
        
        bitPosition += 4;
        if (bitPosition >= 8) {
          bitPosition = 0;
          byteIndex++;
        }
      }
    }
    return board;
  }
}
