// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart';

// ================= WARNA TEMA (TIDAK DIUBAH) =================
const Color kPrimaryColor = Color(0xFF6ABF4B);
const Color kTextColor = Color(0xFF202E2E);
const Color kTextLightColor = Color(0xFF728080);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kede Grocery App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: kPrimaryColor,

        // ================= TEXT THEME =================
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            color: kTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
          bodyMedium: TextStyle(
            color: kTextLightColor,
            fontSize: 16,
          ),
        ),

        // ================= ELEVATED BUTTON =================
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // ================= OUTLINED BUTTON =================
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: kPrimaryColor, width: 2),
            foregroundColor: kPrimaryColor,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      // ================= ENTRY SCREEN =================
      home: const OnboardingScreen(),
    );
  }
}
