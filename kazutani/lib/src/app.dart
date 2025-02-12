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
    return MaterialApp(
      navigatorKey: navigatorKey,
      initialRoute: AppRoutes.home,
      routes: {
        '/': (context) => HomeScreen(),
        '/game': (context) => GameScreen(),
        '/settings': (context) => SettingsScreen(controller: settingsController),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
