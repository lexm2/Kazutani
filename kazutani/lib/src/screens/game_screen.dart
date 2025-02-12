import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/game_state.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameState>().startNewGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Game'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () => context.read<GameState>().completeGameTest(),
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => gameState.resetGame(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 9,
                childAspectRatio: 1.0,
                crossAxisSpacing: 1.0,
                mainAxisSpacing: 1.0,
              ),
              itemCount: 81,
              itemBuilder: (context, index) {
                final row = index ~/ 9;
                final col = index % 9;
                return _buildCell(context, row, col);
              },
            ),
          ),
          _buildNumberPad(),
        ],
      ),
    );
  }

  Widget _buildCell(BuildContext context, int row, int col) {
    final gameState = context.watch<GameState>();
    final isSelected =
        gameState.selectedRow == row && gameState.selectedCol == col;
    final number = gameState.board[row][col];
    final isOriginal = gameState.isOriginal[row][col];

    return GestureDetector(
      onTap: () => gameState.selectCell(row, col),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withAlpha(76) : Colors.white,
          border: Border(
            right: BorderSide(
              width: (col + 1) % 3 == 0 ? 2.0 : 1.0,
              color: (col + 1) % 3 == 0 ? Colors.black : Colors.grey,
            ),
            bottom: BorderSide(
              width: (row + 1) % 3 == 0 ? 2.0 : 1.0,
              color: (row + 1) % 3 == 0 ? Colors.black : Colors.grey,
            ),
            left: BorderSide(
              width: col % 3 == 0 ? 2.0 : 1.0,
              color: col % 3 == 0 ? Colors.black : Colors.grey,
            ),
            top: BorderSide(
              width: row % 3 == 0 ? 2.0 : 1.0,
              color: row % 3 == 0 ? Colors.black : Colors.grey,
            ),
          ),
        ),
        child: Center(
          child: Text(
            number == 0 ? '' : number.toString(),
            style: TextStyle(
              color: isOriginal ? Colors.black : Colors.blue,
              fontWeight: isOriginal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          childAspectRatio: 1.5,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          return ElevatedButton(
            onPressed: () => context.read<GameState>().setNumber(index + 1),
            child: Text('${index + 1}'),
          );
        },
      ),
    );
  }
}
