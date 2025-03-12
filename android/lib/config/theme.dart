import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Waste2Way brand colors
  static const Color teal = Color(0xFF2A9D8F);
  static const Color green = Color(0xFF57CC99);
  static const Color blue = Color(0xFF48CAE4);
  static const Color navy = Color(0xFF023E8A);
  static const Color coral = Color(0xFFF4845F);
  static const Color dark = Color(0xFF1A1E23);
  static const Color light = Color(0xFFF8F9FA);

  static const Color primaryColor = teal;
  static const Color secondaryColor = green;
  static const Color backgroundColor1 = backgroundLight;
  static const Color backgroundColor2 = light;
  static const Color textPrimaryColor = foregroundLight;

  // Light theme colors
  static const Color backgroundLight = Color(
    0xFFF8F9FA,
  ); // --background: 210 20% 98%
  static const Color foregroundLight = Color(
    0xFF141C2F,
  ); // --foreground: 222 47% 11%

  static const Color cardLight = Color(0xFFFFFFFF); // --card: 0 0% 100%
  static const Color cardForegroundLight = Color(
    0xFF141C2F,
  ); // --card-foreground: 222 47% 11%

  static const Color popoverLight = Color(0xFFFFFFFF); // --popover: 0 0% 100%
  static const Color popoverForegroundLight = Color(
    0xFF141C2F,
  ); // --popover-foreground: 222 47% 11%

  static const Color mutedLight = Color(0xFFF1F5F9); // --muted: 210 40% 96%
  static const Color mutedForegroundLight = Color(
    0xFF64748B,
  ); // --muted-foreground: 215 16% 47%

  static const Color destructiveLight = Color(
    0xFFEF4444,
  ); // --destructive: 0 84% 60%
  static const Color destructiveForegroundLight = Color(
    0xFFF8FAFC,
  ); // --destructive-foreground: 210 40% 98%

  static const Color borderLight = Color(0xFFE2E8F0); // --border: 214 32% 91%
  static const Color inputLight = Color(0xFFE2E8F0); // --input: 214 32% 91%

  // Dark theme colors
  static const Color backgroundDark = Color(
    0xFF141C2F,
  ); // --background: 222 47% 10%
  static const Color foregroundDark = Color(
    0xFFF8FAFC,
  ); // --foreground: 210 40% 98%

  static const Color cardDark = Color(0xFF111827); // --card: 222 47% 9%
  static const Color cardForegroundDark = Color(
    0xFFF8FAFC,
  ); // --card-foreground: 210 40% 98%

  static const Color popoverDark = Color(0xFF141C2F); // --popover: 222 47% 10%
  static const Color popoverForegroundDark = Color(
    0xFFF8FAFC,
  ); // --popover-foreground: 210 40% 98%

  static const Color mutedDark = Color(0xFF1F2937); // --muted: 217 33% 17%
  static const Color mutedForegroundDark = Color(
    0xFF94A3B8,
  ); // --muted-foreground: 215 20% 65%

  static const Color destructiveDark = Color(
    0xFF7F1D1D,
  ); // --destructive: 0 62% 30%
  static const Color destructiveForegroundDark = Color(
    0xFFF8FAFC,
  ); // --destructive-foreground: 210 40% 98%

  static const Color borderDark = Color(0xFF1F2937); // --border: 217 33% 17%
  static const Color inputDark = Color(0xFF1F2937); // --input: 217 33% 17%

  // Create a method to set appropriate status bar style
  static void setStatusBarStyle({bool darkMode = false}) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: darkMode ? Brightness.light : Brightness.dark,
        statusBarBrightness: darkMode ? Brightness.dark : Brightness.light,
      ),
    );
  }

  // Create a ThemeData instance to use with MaterialApp
  static ThemeData get lightTheme {
    // Set status bar for light theme
    setStatusBarStyle(darkMode: false);

    return ThemeData(
      useMaterial3: true,
      primaryColor: teal,
      fontFamily: 'Inter', // Set Inter as default font
      colorScheme: ColorScheme.light(
        primary: teal, // --primary: 184 48% 40%
        onPrimary: light, // --primary-foreground: 210 40% 98%
        secondary: green, // --secondary: 160 53% 57%
        onSecondary: dark, // --secondary-foreground: 222 47% 11%
        tertiary: blue, // --accent: 199 84% 59%
        onTertiary: dark, // --accent-foreground: 222 47% 11%
        error: coral, // --destructive
        onError: light, // --destructive-foreground
        background: backgroundLight,
        onBackground: foregroundLight,
        surface: cardLight,
        onSurface: cardForegroundLight,
      ),
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: teal,
        foregroundColor: light,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        // Apply Inter font to AppBar
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: const CardTheme(color: cardLight, elevation: 2),
      dialogTheme: const DialogTheme(
        backgroundColor: popoverLight,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: teal, width: 2),
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(
        TextTheme(
          displayLarge: TextStyle(color: foregroundLight),
          displayMedium: TextStyle(color: foregroundLight),
          displaySmall: TextStyle(color: foregroundLight),
          headlineLarge: TextStyle(color: foregroundLight),
          headlineMedium: TextStyle(color: foregroundLight),
          headlineSmall: TextStyle(color: foregroundLight),
          titleLarge: TextStyle(color: foregroundLight),
          titleMedium: TextStyle(color: foregroundLight),
          titleSmall: TextStyle(color: foregroundLight),
          bodyLarge: TextStyle(color: foregroundLight),
          bodyMedium: TextStyle(color: foregroundLight),
          bodySmall: TextStyle(color: mutedForegroundLight),
        ),
      ),
      dividerTheme: DividerThemeData(color: borderLight),
    );
  }

  // Dark theme
  static ThemeData get darkTheme {
    // Set status bar for dark theme
    setStatusBarStyle(darkMode: true);

    return ThemeData(
      useMaterial3: true,
      primaryColor: teal,
      fontFamily: 'Inter', // Set Inter as default font
      colorScheme: ColorScheme.dark(
        primary: teal, // --primary: 184 48% 40%
        onPrimary: light, // --primary-foreground: 210 40% 98%
        secondary: green, // --secondary: 160 53% 57%
        onSecondary: dark, // --secondary-foreground: 222 47% 11%
        tertiary: blue, // --accent: 199 84% 59%
        onTertiary: light, // --accent-foreground: 210 40% 98%
        error: coral, // --destructive
        onError: light, // --destructive-foreground
        background: backgroundDark,
        onBackground: foregroundDark,
        surface: cardDark,
        onSurface: cardForegroundDark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: dark,
        foregroundColor: light,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      cardTheme: const CardTheme(color: cardDark, elevation: 2),
      dialogTheme: const DialogTheme(
        backgroundColor: popoverDark,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: teal, width: 2),
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(
        TextTheme(
          displayLarge: TextStyle(color: foregroundDark),
          displayMedium: TextStyle(color: foregroundDark),
          displaySmall: TextStyle(color: foregroundDark),
          headlineLarge: TextStyle(color: foregroundDark),
          headlineMedium: TextStyle(color: foregroundDark),
          headlineSmall: TextStyle(color: foregroundDark),
          titleLarge: TextStyle(color: foregroundDark),
          titleMedium: TextStyle(color: foregroundDark),
          titleSmall: TextStyle(color: foregroundDark),
          bodyLarge: TextStyle(color: foregroundDark),
          bodyMedium: TextStyle(color: foregroundDark),
          bodySmall: TextStyle(color: mutedForegroundDark),
        ),
      ),
      dividerTheme: DividerThemeData(color: borderDark),
    );
  }
}
