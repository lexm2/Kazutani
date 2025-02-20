import 'package:flutter/material.dart';
import '../settings/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsController controller;

  const SettingsScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text('Theme', style: Theme.of(context).textTheme.titleLarge),
            AnimatedBuilder(
              animation: controller,
              builder: (BuildContext context, Widget? child) {
                return ListTile(
                  title: Text('Dark Mode'),
                  trailing: Switch(
                    value: controller.themeMode == ThemeMode.dark,
                    onChanged: (bool value) {
                      controller.updateThemeMode(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
