import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(_loadTheme()) {
    _loadTheme();
  }

  static ThemeMode _loadTheme() {
    final isDark = StorageService.settingsBox.get('isDarkMode', defaultValue: false);
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() async {
    if (state == ThemeMode.light) {
      state = ThemeMode.dark;
      await StorageService.settingsBox.put('isDarkMode', true);
    } else {
      state = ThemeMode.light;
      await StorageService.settingsBox.put('isDarkMode', false);
    }
  }
}
