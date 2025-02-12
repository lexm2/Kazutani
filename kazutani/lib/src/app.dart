import 'package:flutter/material.dart';

import 'settings/settings_controller.dart';

import 'screens/home_screen.dart';
import 'routes.dart';

class MyApp extends StatelessWidget {
  final SettingsController settingsController;

  const MyApp({Key? key, required this.settingsController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (context) => HomeScreen(),
        // AppRoutes.game: (context) => GameScreen(),
        // AppRoutes.settings: (context) => SettingsScreen(controller: settingsController),
      },
    );
  }
}