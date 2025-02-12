import 'package:flutter/foundation.dart';

class GameState extends ChangeNotifier {
  List<List<int>> board = List.generate(9, (_) => List.filled(9, 0));
  
  List<List<bool>> isOriginal = List.generate(9, (_) => List.filled(9, false));
  
  int selectedRow = -1;
  int selectedCol = -1;

  void selectCell(int row, int col) {
    selectedRow = row;
    selectedCol = col;
    notifyListeners();
  }

  void setNumber(int number) {
    if (selectedRow != -1 && selectedCol != -1 && !isOriginal[selectedRow][selectedCol]) {
      board[selectedRow][selectedCol] = number;
      notifyListeners();
    }
  }

  bool isValid(int row, int col, int number) {
    // Add validation logic here
    return true;
  }
}
