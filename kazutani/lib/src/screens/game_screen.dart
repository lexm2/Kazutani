import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/game_state.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  static const double CELL_SIZE = 40.0; // Base cell size
  static const double CELL_SPACING = 1.0; // Space between cells
  static const double CELL_TOTAL = CELL_SIZE + CELL_SPACING;

  final Map<int, GlobalKey> cellKeys = {
    for (var i = 0; i < 81; i++) i: GlobalKey()
  };
  Offset? panStart;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < 81; i++) {
        RenderBox? box =
            cellKeys[i]?.currentContext?.findRenderObject() as RenderBox?;
        if (box != null) {
          final position = box.localToGlobal(Offset.zero);
          context.read<GameState>().updateCellBound(i, position);
        } else {
          print("Error: box is null for cell $i");
        }
      }
    });
  }

  bool isPointerInCell(Offset pointerPosition, Offset cellPosition) {
    return pointerPosition.dx >= cellPosition.dx &&
        pointerPosition.dx <= cellPosition.dx + CELL_SIZE &&
        pointerPosition.dy >= cellPosition.dy &&
        pointerPosition.dy <= cellPosition.dy + CELL_SIZE;
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.undo),
            onPressed: () => context.read<GameState>().undo(),
          ),
          IconButton(
            icon: Icon(Icons.redo),
            onPressed: () => context.read<GameState>().redo(),
          ),
          IconButton(
            icon: Icon(Icons.auto_fix_high),
            onPressed: () => context.read<GameState>().solveAsPlayer(),
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => gameState.startNewGame(),
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
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                maxHeight: MediaQuery.of(context).size.width * 0.9,
              ),
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (event) {
                  gameState.isDragging = true;
                  for (var entry in gameState.cellBounds.entries) {
                    if (isPointerInCell(event.position, entry.value)) {
                      gameState.selectSingleCell(entry.key);
                      break;
                    }
                  }
                },
                onPointerMove: (event) {
                  if (gameState.isDragging) {
                    for (var entry in gameState.cellBounds.entries) {
                      if (isPointerInCell(event.position, entry.value)) {
                        gameState.selectCell(entry.key);
                        break;
                      }
                    }
                  }
                },
                onPointerUp: (event) {
                  gameState.isDragging = false;
                },
                child: GridView.builder(
                  padding: EdgeInsets.all(16.0),
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 9,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 1.0,
                    mainAxisSpacing: 1.0,
                  ),
                  itemCount: 81,
                  itemBuilder: (context, position) =>
                      _buildCell(context, position),
                ),
              ),
            ),
          ),
          _buildNumberPad(context),
        ],
      ),
    );
  }
  Widget _buildCell(BuildContext context, int cellIndex) {
    final gameState = context.watch<GameState>();
    final cell = gameState.currentBoard.cells[cellIndex];
    final value = cell.value;
    final isOriginal = cell.isOriginal;
    final notes = cell.notes;
    final isSelected = gameState.selectedCells.contains(cellIndex);

    return Container(
        key: cellKeys[cellIndex],
        child: AnimatedContainer(
          duration: Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withAlpha(76)
                : Theme.of(context).colorScheme.surface,
            border: Border(
              right: BorderSide(
                width: (cellIndex + 1) % 3 == 0 ? 2.0 : 1.0,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(20),
              ),
              bottom: BorderSide(
                width: ((cellIndex ~/ 9) + 1) % 3 == 0 ? 2.0 : 1.0,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(20),
              ),
              left: BorderSide(
                width: cellIndex % 3 == 0 ? 2.0 : 1.0,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(20),
              ),
              top: BorderSide(
                width: (cellIndex ~/ 9) % 3 == 0 ? 2.0 : 1.0,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(20),
              ),
            ),
          ),
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 150),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: value != 0
                ? Center(
                    child: Text(
                      value.toString(),
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
                    physics: NeverScrollableScrollPhysics(),
                    children: List.generate(9, (index) {
                      return Center(
                        child: notes.contains(index + 1)
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
        ));
  }

  Widget _buildNumberPad(BuildContext context) {
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
