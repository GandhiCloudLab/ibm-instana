import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get themeData {
    return _isDarkMode ? _darkTheme : _lightTheme;
  }

  // Light theme with vibrant colors
  static final ThemeData _lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
      primary: const Color(0xFF1976D2),
      secondary: const Color(0xFF26A69A),
      tertiary: const Color(0xFF7E57C2),
      surface: const Color(0xFFF5F7FA),
      background: const Color(0xFFE8EAF6),
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F7FA),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 2,
      backgroundColor: Color(0xFF1976D2),
      foregroundColor: Colors.white,
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF26A69A),
      foregroundColor: Colors.white,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFE3F2FD),
      labelStyle: const TextStyle(color: Color(0xFF1976D2)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  // Dark theme with rich colors
  static final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
      primary: const Color(0xFF64B5F6),
      secondary: const Color(0xFF4DB6AC),
      tertiary: const Color(0xFFBA68C8),
      surface: const Color(0xFF1E1E1E),
      background: const Color(0xFF121212),
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 2,
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Color(0xFF64B5F6),
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      color: Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF4DB6AC),
      foregroundColor: Colors.white,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF1E3A5F),
      labelStyle: const TextStyle(color: Color(0xFF64B5F6)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  // Load theme preference
  Future<void> loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
    }
  }

  // Toggle theme
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _isDarkMode);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  // Set theme explicitly
  Future<void> setTheme(bool isDark) async {
    _isDarkMode = isDark;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _isDarkMode);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }
}

// Made with Bob
