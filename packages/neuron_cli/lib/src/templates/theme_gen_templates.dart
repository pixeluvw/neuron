import 'package:recase/recase.dart';

/// Templates for theme generation
class ThemeGenTemplates {
  /// Generate a complete light/dark theme file
  static String themeDart({
    required String seedColor,
    required String style,
  }) {
    final colorHex = _resolveColor(seedColor);

    return switch (style) {
      'glassmorphic' => _glassmorphicTheme(colorHex),
      'minimal' => _minimalTheme(colorHex),
      _ => _materialTheme(colorHex),
    };
  }

  /// Generate a theme controller for runtime theme switching
  static String themeControllerDart() {
    return '''
import 'package:flutter/material.dart';
import 'package:neuron/neuron.dart';

/// Controller for managing app theme at runtime
///
/// Usage:
/// ```dart
/// final tc = ThemeController.init;
/// tc.toggleTheme();        // Switch light/dark
/// tc.setThemeMode(ThemeMode.dark);
/// ```
class ThemeController extends NeuronController {
  static ThemeController get init =>
      Neuron.ensure<ThemeController>(() => ThemeController());

  /// Current theme mode
  late final themeMode = Signal<ThemeMode>(ThemeMode.system).bind(this);

  /// Whether dark mode is active (resolved from system if needed)
  bool get isDark => themeMode.val == ThemeMode.dark;

  /// Toggle between light and dark mode
  void toggleTheme() {
    themeMode.emit(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  /// Set a specific theme mode
  void setThemeMode(ThemeMode mode) {
    themeMode.emit(mode);
  }
}
''';
  }

  static String _resolveColor(String color) {
    final named = {
      'red': '0xFFF44336',
      'pink': '0xFFE91E63',
      'purple': '0xFF9C27B0',
      'deep-purple': '0xFF673AB7',
      'indigo': '0xFF3F51B5',
      'blue': '0xFF2196F3',
      'light-blue': '0xFF03A9F4',
      'cyan': '0xFF00BCD4',
      'teal': '0xFF009688',
      'green': '0xFF4CAF50',
      'lime': '0xFFCDDC39',
      'yellow': '0xFFFFEB3B',
      'amber': '0xFFFFC107',
      'orange': '0xFFFF9800',
      'deep-orange': '0xFFFF5722',
      'brown': '0xFF795548',
      'grey': '0xFF9E9E9E',
      'violet': '0xFF8B5CF6',
    };

    final rc = ReCase(color);
    if (named.containsKey(rc.paramCase)) {
      return named[rc.paramCase]!;
    }

    // If it looks like a hex color already
    if (color.startsWith('0x') || color.startsWith('#')) {
      final hex = color.replaceFirst('#', '0xFF');
      return hex;
    }

    // Default to indigo
    return '0xFF3F51B5';
  }

  static String _materialTheme(String colorHex) {
    return '''
import 'package:flutter/material.dart';

/// App theme configuration (Material 3)
class AppTheme {
  AppTheme._();

  static const _seedColor = Color($colorHex);

  /// Light theme
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );

  /// Dark theme
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
}
''';
  }

  static String _minimalTheme(String colorHex) {
    return '''
import 'package:flutter/material.dart';

/// App theme configuration (Minimal)
class AppTheme {
  AppTheme._();

  static const _seedColor = Color($colorHex);

  /// Light theme - clean and minimal
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
        dividerTheme: const DividerThemeData(space: 1),
      );

  /// Dark theme - clean and minimal
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
        dividerTheme: const DividerThemeData(space: 1),
      );
}
''';
  }

  static String _glassmorphicTheme(String colorHex) {
    return '''
import 'package:flutter/material.dart';

/// App theme configuration (Glassmorphic)
class AppTheme {
  AppTheme._();

  static const _primaryColor = Color($colorHex);
  static const _surfaceColor = Color(0xFF1E293B);
  static const _backgroundColor = Color(0xFF0F172A);

  /// Light theme
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      );

  /// Dark theme (Primary Experience - Glassmorphic)
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _backgroundColor,
        colorScheme: ColorScheme.dark(
          primary: _primaryColor,
          surface: _surfaceColor,
          onSurface: Colors.white,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32, fontWeight: FontWeight.bold,
            letterSpacing: -1.0, color: Colors.white,
          ),
          headlineMedium: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w600,
            letterSpacing: -0.5, color: Colors.white,
          ),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
        ),
        cardTheme: CardThemeData(
          color: _surfaceColor.withValues(alpha: 0.4),
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
      );
}
''';
  }
}
