// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme(bool isOn) {
    _isDarkMode = isOn;
    notifyListeners();
  }

  ThemeData get currentTheme => _isDarkMode ? ThemeData.dark() : ThemeData.light();
}
