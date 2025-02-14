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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final gameState = context.read<GameState>();
      await gameState.loadLastGame();
      if (GameState.cells.every((cell) => cell.value == 0)) {
        gameState.startNewGame();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => gameState.resetGame(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              '${context.watch<GameState>().moveCount}',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
                    itemBuilder: (context, position) {
                      return _buildCell(context, position);
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

  Widget _buildCell(BuildContext context, int position) {
    final gameState = context.watch<GameState>();
    final cell = GameState.cells[position];
    final isSelected = gameState.selectedCell == position;

    return GestureDetector(
      onTap: () => gameState.selectCell(position),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withAlpha(76)
              : Theme.of(context).colorScheme.surface,
          border: Border(
            right: BorderSide(
              width: cell.rightBorderWidth,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(20),
            ),
            bottom: BorderSide(
              width: cell.bottomBorderWidth,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(20),
            ),
            left: BorderSide(
              width: cell.leftBorderWidth,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(20),
            ),
            top: BorderSide(
              width: cell.topBorderWidth,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(20),
            ),
          ),
        ),
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 150),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: cell.value != 0
              ? Center(
                  child: Text(
                    cell.value.toString(),
                    style: TextStyle(
                      color: cell.isOriginal
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.secondary,
                      fontWeight:
                          cell.isOriginal ? FontWeight.bold : FontWeight.normal,
                      fontSize: 24,
                    ),
                  ),
                )
              : GridView.count(
                  crossAxisCount: 3,
                  padding: EdgeInsets.all(2),
                  children: List.generate(9, (index) {
                    return Center(
                      child: cell.notes.contains(index + 1)
                          ? Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withAlpha(80),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
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
            itemCount: 10,
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
