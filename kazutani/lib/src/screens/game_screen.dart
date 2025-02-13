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
  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Game'),
            Row(
              children: [
                Icon(Icons.score),
                SizedBox(width: 8),
                Text('${context.watch<GameState>().moveCount}'),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => gameState.resetGame(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                    maxHeight: MediaQuery.of(context).size.width * 0.9,
                  ),
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
              ),
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
    final notes = gameState.notes[row][col];

    return GestureDetector(
      onTap: () => gameState.selectCell(row, col),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withAlpha(76)
              : Theme.of(context).colorScheme.surface,
          border: Border(
            right: BorderSide(
              width: (col + 1) % 3 == 0 ? 2.0 : 1.0,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(20),
            ),
            bottom: BorderSide(
              width: (row + 1) % 3 == 0 ? 2.0 : 1.0,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(20),
            ),
            left: BorderSide(
              width: col % 3 == 0 ? 2.0 : 1.0,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(20),
            ),
            top: BorderSide(
              width: row % 3 == 0 ? 2.0 : 1.0,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(20),
            ),
          ),
        ),
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: number != 0
              ? Center(
                  child: Text(
                    number.toString(),
                    style: TextStyle(
                      color: isOriginal
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.secondary,
                      fontWeight:
                          isOriginal ? FontWeight.bold : FontWeight.normal,
                      fontSize: 24,
                    ),
                  ),
                )
              : GridView.count(
                  crossAxisCount: 3,
                  padding: EdgeInsets.all(2),
                  children: List.generate(9, (index) {
                    return Center(
                      child: notes.contains(index + 1)
                          ? Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withAlpha(20),
                                fontSize: 10,
                              ),
                            )
                          : null,
                    );
                  }),
                ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: TextButton.icon(
                  icon: Icon(
                    Icons.edit_note,
                    color: context.watch<GameState>().isNoteMode
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  label: Text(
                    'Notes',
                    style: TextStyle(
                      color: context.watch<GameState>().isNoteMode
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  onPressed: () => context.read<GameState>().toggleNoteMode(),
                  style: TextButton.styleFrom(
                    backgroundColor: context.watch<GameState>().isNoteMode
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 1.5,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: 10, // 9 numbers + delete
            itemBuilder: (context, index) {
              if (index == 9) {
                return ElevatedButton(
                  onPressed: () => context.read<GameState>().clearCell(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  child: Icon(
                    Icons.backspace,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                );
              }
              return ElevatedButton(
                onPressed: () => context.read<GameState>().setNumber(index + 1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 18,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
