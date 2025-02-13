import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

class SettingsService {
  final dbHelper = DatabaseHelper();

  Future<ThemeMode> themeMode() async {
    final db = await dbHelper.database;
    final result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: ['theme'],
    );

    if (result.isEmpty) return ThemeMode.system;

    final themeString = result.first['value'] as String;
    return ThemeMode.values.firstWhere(
      (e) => e.toString() == themeString,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> updateThemeMode(ThemeMode theme) async {
    final db = await dbHelper.database;
    await db.insert(
      'settings',
      {'key': 'theme', 'value': theme.toString()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
