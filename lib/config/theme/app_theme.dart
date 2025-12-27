import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colores mate/pasteles para el tema
class AppColors {
  // Light theme colors
  static const Color lightPrimary = Color(0xFF4A90E2); // Azul mate
  static const Color lightSecondary = Color(0xFF7B8FA1); // Azul grisáceo
  static const Color lightBackground =
      Color(0xFFF5F7FA); // Blanco azulado muy claro
  static const Color lightSurface = Colors.white;
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF2C3E50); // Gris oscuro
  static const Color lightTextSecondary = Color(0xFF7B8FA1);
  static const Color lightBorder = Color(0xFFE1E8ED);
  static const Color lightSuccess = Color(0xFF52C41A); // Verde mate
  static const Color lightError = Color(0xFFF5222D); // Rojo mate
  static const Color lightWarning = Color(0xFFFAAD14); // Amarillo mate

  // Dark theme colors
  static const Color darkPrimary =
      Color(0xFF5BA3F5); // Azul más claro para dark
  static const Color darkSecondary = Color(0xFF8FA8C2);
  static const Color darkBackground = Color(0xFF1A1F2E); // Azul muy oscuro
  static const Color darkSurface = Color(0xFF252B3D); // Azul oscuro
  static const Color darkCard = Color(0xFF2D3447);
  static const Color darkText = Color(0xFFE8EDF3); // Blanco azulado
  static const Color darkTextSecondary = Color(0xFF9CA3B0);
  static const Color darkBorder = Color(0xFF3A4255);
  static const Color darkSuccess = Color(0xFF73D13D);
  static const Color darkError = Color(0xFFFF4D4F);
  static const Color darkWarning = Color(0xFFFFC53D);
}

/// Helper para detectar la plataforma
class PlatformHelper {
  static bool get isIOS => Platform.isIOS;
  static bool get isAndroid => Platform.isAndroid;
  static bool get isMobile => isIOS || isAndroid;
}

class AppTheme {
  /// Obtiene el tema según la plataforma y modo (light/dark)
  ThemeData getTheme({bool isDark = false}) {
    if (PlatformHelper.isIOS) {
      return _getIOSTheme(isDark: isDark);
    } else {
      return _getAndroidTheme(isDark: isDark);
    }
  }

  /// Obtiene el tema Cupertino para iOS
  CupertinoThemeData getCupertinoTheme({bool isDark = false}) {
    final colors = isDark ? _darkColors : _lightColors;

    return CupertinoThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: colors['primary']!,
      scaffoldBackgroundColor: colors['background']!,
      barBackgroundColor: colors['background']!,
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(
          color: colors['text']!,
          fontSize: 17,
          letterSpacing: -0.41,
        ),
        navTitleTextStyle: TextStyle(
          color: colors['text']!,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.41,
        ),
        navLargeTitleTextStyle: TextStyle(
          color: colors['text']!,
          fontSize: 34,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.37,
        ),
        navActionTextStyle: TextStyle(
          color: colors['primary']!,
          fontSize: 17,
          letterSpacing: -0.41,
        ),
        pickerTextStyle: TextStyle(
          color: colors['text']!,
          fontSize: 21,
          letterSpacing: 0.16,
        ),
        dateTimePickerTextStyle: TextStyle(
          color: colors['text']!,
          fontSize: 21,
          letterSpacing: 0.16,
        ),
        tabLabelTextStyle: TextStyle(
          color: colors['text']!,
          fontSize: 10,
          letterSpacing: -0.24,
        ),
      ),
    );
  }

  /// Tema estilo iOS
  ThemeData _getIOSTheme({bool isDark = false}) {
    final colors = isDark ? _darkColors : _lightColors;

    return ThemeData(
      useMaterial3: true,
      platform: TargetPlatform.iOS,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: colors['primary']!,
        secondary: colors['secondary']!,
        surface: colors['surface']!,
        error: colors['error']!,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: colors['text']!,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: colors['background']!,
      appBarTheme: AppBarTheme(
        backgroundColor: colors['background']!,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: colors['text']!,
          letterSpacing: -0.41,
        ),
        iconTheme: IconThemeData(
          color: colors['primary']!,
          size: 28,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: colors['text']!,
          letterSpacing: 0.37,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: colors['text']!,
          letterSpacing: 0.36,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: colors['text']!,
          letterSpacing: 0.35,
        ),
        titleMedium: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: colors['text']!,
          letterSpacing: -0.41,
        ),
        bodyLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.normal,
          color: colors['text']!,
          letterSpacing: -0.41,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.normal,
          color: colors['textSecondary']!,
          letterSpacing: -0.24,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.normal,
          color: colors['textSecondary']!,
          letterSpacing: -0.08,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(colors['primary']!),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevation: WidgetStateProperty.all(0),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors['surface']!,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors['border']!, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors['border']!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors['primary']!, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardThemeData(
        color: colors['card']!,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors['border']!, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  /// Tema estilo Android
  ThemeData _getAndroidTheme({bool isDark = false}) {
    final colors = isDark ? _darkColors : _lightColors;

    return ThemeData(
      useMaterial3: true,
      platform: TargetPlatform.android,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: colors['primary']!,
        secondary: colors['secondary']!,
        surface: colors['surface']!,
        error: colors['error']!,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: colors['text']!,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: colors['background']!,
      appBarTheme: AppBarTheme(
        backgroundColor: colors['background']!,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colors['text']!,
        ),
        iconTheme: IconThemeData(
          color: colors['text']!,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.roboto(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          color: colors['text']!,
        ),
        headlineLarge: GoogleFonts.roboto(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          color: colors['text']!,
        ),
        titleLarge: GoogleFonts.roboto(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colors['text']!,
        ),
        titleMedium: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colors['text']!,
        ),
        bodyLarge: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: colors['text']!,
        ),
        bodyMedium: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: colors['textSecondary']!,
        ),
        bodySmall: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: colors['textSecondary']!,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(colors['primary']!),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevation: WidgetStateProperty.all(0),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors['surface']!,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors['border']!, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors['border']!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors['primary']!, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardThemeData(
        color: colors['card']!,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors['border']!, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Map<String, Color> get _lightColors => {
        'primary': AppColors.lightPrimary,
        'secondary': AppColors.lightSecondary,
        'background': AppColors.lightBackground,
        'surface': AppColors.lightSurface,
        'card': AppColors.lightCard,
        'text': AppColors.lightText,
        'textSecondary': AppColors.lightTextSecondary,
        'border': AppColors.lightBorder,
        'error': AppColors.lightError,
        'success': AppColors.lightSuccess,
        'warning': AppColors.lightWarning,
      };

  Map<String, Color> get _darkColors => {
        'primary': AppColors.darkPrimary,
        'secondary': AppColors.darkSecondary,
        'background': AppColors.darkBackground,
        'surface': AppColors.darkSurface,
        'card': AppColors.darkCard,
        'text': AppColors.darkText,
        'textSecondary': AppColors.darkTextSecondary,
        'border': AppColors.darkBorder,
        'error': AppColors.darkError,
        'success': AppColors.darkSuccess,
        'warning': AppColors.darkWarning,
      };
}

/// Helper para calcular tamaños responsivos basados en el ancho de pantalla
class ResponsiveHelper {
  static double responsiveFontSize(
    BuildContext context, {
    required double baseSize,
    double? minSize,
    double? maxSize,
  }) {
    final width = MediaQuery.of(context).size.width;
    final scaleFactor = width / 360.0;
    var fontSize = baseSize * scaleFactor;

    if (minSize != null && fontSize < minSize) fontSize = minSize;
    if (maxSize != null && fontSize > maxSize) fontSize = maxSize;

    return fontSize;
  }

  static double responsivePadding(
    BuildContext context, {
    required double basePadding,
    double? minPadding,
    double? maxPadding,
  }) {
    final width = MediaQuery.of(context).size.width;
    final scaleFactor = width / 360.0;
    var padding = basePadding * scaleFactor;

    if (minPadding != null && padding < minPadding) padding = minPadding;
    if (maxPadding != null && padding > maxPadding) padding = maxPadding;

    return padding;
  }

  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 1;
    } else {
      return 2;
    }
  }

  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 900;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }
}

/// Extension para acceder a los colores fácilmente
extension AppColorsExtension on AppColors {
  static Map<String, Color> get lightColors => {
        'primary': AppColors.lightPrimary,
        'secondary': AppColors.lightSecondary,
        'background': AppColors.lightBackground,
        'surface': AppColors.lightSurface,
        'card': AppColors.lightCard,
        'text': AppColors.lightText,
        'textSecondary': AppColors.lightTextSecondary,
        'border': AppColors.lightBorder,
        'error': AppColors.lightError,
        'success': AppColors.lightSuccess,
        'warning': AppColors.lightWarning,
      };

  static Map<String, Color> get darkColors => {
        'primary': AppColors.darkPrimary,
        'secondary': AppColors.darkSecondary,
        'background': AppColors.darkBackground,
        'surface': AppColors.darkSurface,
        'card': AppColors.darkCard,
        'text': AppColors.darkText,
        'textSecondary': AppColors.darkTextSecondary,
        'border': AppColors.darkBorder,
        'error': AppColors.darkError,
        'success': AppColors.darkSuccess,
        'warning': AppColors.darkWarning,
      };
}
