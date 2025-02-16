import '../utils/sudoku_loader.dart';
import 'cell.dart';

class SudokuLogic {
  Future<List<Cell>> getNewGame() async {
    print('Loading game from CSV...');
    List<Cell> cells = await SudokuLoader.getRandomGame();
    print('Game loaded successfully!');
    return cells;
  }
}
