import 'package:flutter/services.dart' show rootBundle;
import 'dart:math';
import '../game/cell.dart';

class SudokuLoader {
  static const String csvPath = 'assets/sudoku_games.csv';
  static List<String>? _games;

  static Future<List<Cell>> getRandomGame() async {
    if (_games == null) {
      final String content = await rootBundle.loadString(csvPath);
      _games = content.split('\n');
    }

    final random = Random();
    final selectedLine = _games![random.nextInt(_games!.length)];

    final parts = selectedLine.split(',');
    final puzzleString = parts[0];

    return List.generate(81, (index) {
      final value = int.parse(puzzleString[index]);
      final cell = Cell(index, value: value);
      if (value != 0) {
        cell.markAsOriginal();
      }
      return cell;
    });
  }
}
