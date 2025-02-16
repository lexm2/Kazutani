import 'package:flutter/material.dart';

import 'screens/game_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'settings/settings_controller.dart';

import 'screens/home_screen.dart';

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
              primary: Color(0xFFFFB7C5), // Light sakura pink
              secondary: Color(0xFFFFC9D4), // Lighter sakura pink
              surface: Colors.white,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.dark(
              primary: Color(0xFFFF8FA5), // Deeper sakura pink
              secondary: Colors.grey[300]!, // Light grey
              surface: Colors.black,
              onPrimary: Colors.white,
              onSecondary: Colors.black,
              onSurface: Colors.white,
            ),
          ),
          themeMode: settingsController.themeMode,
          home: SplashScreen(),
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
