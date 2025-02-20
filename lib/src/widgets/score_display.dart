import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game/game_state.dart';

class ScoreDisplay extends StatelessWidget {
  const ScoreDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Moves: ${context.watch<GameState>().moveCount}',
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}
