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
      primary: const Color(0xFF005BAC), // deep blue accent
      onPrimary: Colors.white,
      secondary: const Color(0xFFFFC107), // warm yellow accent for calls
      onSecondary: Colors.black,
      error: Colors.redAccent,
      onError: Colors.white,
      background: const Color(0xFF071024), // very dark background
      onBackground: Colors.white,
      surface: const Color(0xFF0C2540),
      onSurface: Colors.white,
    );

    return MaterialApp(
      title: 'Shanti',
      theme: ThemeData(
        colorScheme: highContrast,
        useMaterial3: true,
        scaffoldBackgroundColor: highContrast.background,
        appBarTheme: AppBarTheme(
          backgroundColor: highContrast.surface,
          foregroundColor: highContrast.onSurface,
          elevation: 2,
          centerTitle: true,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 20.0),
          bodyMedium: TextStyle(fontSize: 18.0),
          labelLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            textStyle: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          ),
        ),
      ),
      home: const VoiceHome(),
    );
  }
}

