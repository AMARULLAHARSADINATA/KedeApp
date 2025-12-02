// lib/screens/auth_screen.dart
import 'dart:ui'; 
import 'package:flutter/material.dart';
import '../widgets/auth_sheets.dart'; 

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showAuthSheet(context, const SignInSheetContent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                // --- MENGGUNAKAN NETWORK IMAGE ---
                // GANTI URL DI BAWAH INI
                image: NetworkImage('https://www.farmersweekly.co.nz/wp-content/uploads/2024/07/supermarket-aisle-scaled-e1721269090566.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}