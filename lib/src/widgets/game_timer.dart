import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game/game_state.dart';

class GameTimer extends StatelessWidget {
  const GameTimer({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Duration>(
      valueListenable: context.watch<GameState>().gameTime,
      builder: (context, duration, child) {
        return Text(
          '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
          style: Theme.of(context).textTheme.headlineSmall,
        );
      },
    );
  }
}
