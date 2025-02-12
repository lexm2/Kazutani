import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game/game_state.dart';

class DifficultySelector extends StatelessWidget {
  const DifficultySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: context.watch<GameState>().difficulty,
      items: ['easy', 'medium', 'hard'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value.toUpperCase()),
        );
      }).toList(),
      onChanged: (newValue) => context.read<GameState>().setDifficulty(newValue!),
    );
  }
}
