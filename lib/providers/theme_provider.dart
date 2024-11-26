import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;
Color customGreen = const Color.fromRGBO(20, 118, 21, 1.0);

  ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      primaryColor: customGreen,
      appBarTheme: AppBarTheme(
        backgroundColor: customGreen,
        titleTextStyle: TextStyle(color: Colors.black),
        iconTheme: IconThemeData(color: const Color.fromARGB(255, 0, 0, 0)),
        
      ),
      // Add more theme customization if needed
    );
  }

  ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: customGreen,
      appBarTheme: AppBarTheme(
        backgroundColor: customGreen,
        titleTextStyle: TextStyle(color: Colors.white),
        iconTheme: IconThemeData(color:  Colors.white),
      ),
      // Add more theme customization if needed
    );
  }

  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners(); // Notify listeners to update the theme
  }
}
