import 'package:flutter/material.dart';
import 'home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final highContrast = ColorScheme(
      brightness: Brightness.dark,
      primary: const Color(0xFF1E88E5), // Vibrant blue for better visibility
      onPrimary: Colors.white,
      secondary: const Color(0xFFFFC107), // Warm yellow accent
      onSecondary: Colors.black,
      error: const Color(0xFFEF5350),
      onError: Colors.white,
      background: const Color(0xFF0A1929), // Deep navy background
      onBackground: Colors.white,
      surface: const Color(0xFF1A2332), // Elevated surface
      onSurface: Colors.white,
      tertiary: const Color(0xFF66BB6A), // Green for success states
      onTertiary: Colors.white,
    );

    return MaterialApp(
      title: 'Shanti AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: highContrast,
        useMaterial3: true,
        scaffoldBackgroundColor: highContrast.background,
        
        appBarTheme: AppBarTheme(
          backgroundColor: highContrast.surface,
          foregroundColor: highContrast.onSurface,
          elevation: 4,
          centerTitle: false,
          titleTextStyle: const TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          titleMedium: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(
            fontSize: 20.0,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 18.0,
            height: 1.4,
          ),
          labelLarge: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
            textStyle: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.0),
            ),
            elevation: 3,
          ),
        ),
        
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          color: highContrast.surface,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
        ),
        
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: highContrast.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: highContrast.primary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: highContrast.primary.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: highContrast.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.all(16.0),
        ),
        
        iconTheme: IconThemeData(
          size: 28,
          color: highContrast.onSurface,
        ),
        
        dividerTheme: DividerThemeData(
          color: Colors.white24,
          thickness: 1.5,
          space: 24,
        ),
        
        snackBarTheme: SnackBarThemeData(
          backgroundColor: highContrast.surface,
          contentTextStyle: const TextStyle(
            fontSize: 18.0,
            color: Colors.white,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        
        dialogTheme: DialogThemeData(
          backgroundColor: highContrast.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          titleTextStyle: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      home: const VoiceHome(),
    );
  }
}