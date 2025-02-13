import 'package:flutter/material.dart';

import 'screens/game_screen.dart';
import 'screens/settings_screen.dart';
import 'settings/settings_controller.dart';

import 'screens/home_screen.dart';
import 'routes.dart';

class MyApp extends StatelessWidget {
  final SettingsController settingsController;
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  const MyApp({super.key, required this.settingsController});
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              secondary: Colors.blueAccent,
              surface: Colors.white,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.dark(
              primary: Colors.blueGrey,
              secondary: Colors.blueGrey[300]!,
              surface: Colors.grey[800]!,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: Colors.white,
            ),
          ),
          themeMode: settingsController.themeMode,
          home: HomeScreen(),
          routes: {
            '/game': (context) => GameScreen(),
            '/settings': (context) => SettingsScreen(
                  controller: settingsController,
                ),
            '/home': (context) => HomeScreen(),
          },
        );
      },
    );
  }
}
