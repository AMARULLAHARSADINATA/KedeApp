// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. IMPORT WAJIB FIREBASE
import 'firebase_options.dart'; // 2. IMPORT FILE KONFIGURASI (Auto-generated)
import 'screens/onboarding_screen.dart';

// Definisikan warna utama kita
const Color kPrimaryColor = Color(0xFF6ABF4B);
const Color kTextColor = Color(0xFF202E2E);
const Color kTextLightColor = Color(0xFF728080);

// 3. UBAH MAIN MENJADI ASYNC
void main() async {
  // 4. PASTIKAN BINDING FLUTTER SIAP
  WidgetsFlutterBinding.ensureInitialized();

  // 5. INISIALISASI FIREBASE
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kede Grocery App',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: kPrimaryColor,
        // Tema untuk font
        textTheme: const TextTheme(
          // Style untuk Judul (cth: "Welcome to Kede!")
          headlineSmall: TextStyle(
            color: kTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
          // Style untuk deskripsi (cth: "Lorem ipsum...")
          bodyMedium: TextStyle(
            color: kTextLightColor,
            fontSize: 16,
          ),
        ),
        // Tema untuk Tombol Utama (Elevated)
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
        // Tema untuk Tombol Kedua (Outlined)
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
        )
      ),
      home: const OnboardingScreen(), // Kembali ke OnboardingScreen
      debugShowCheckedModeBanner: false,
    );
  }
}