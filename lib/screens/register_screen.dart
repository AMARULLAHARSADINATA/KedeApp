// lib/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Definisikan warna tema (agar konsisten dengan main.dart)
const Color kPrimaryColor = Color(0xFF6ABF4B);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controller untuk mengambil teks inputan
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController(); // Tambahan untuk Nama

  bool _isLoading = false; // Status loading saat tombol ditekan
  bool _isPasswordVisible = false; // Untuk mata (show/hide password)

  // --- FUNGSI UTAMA REGISTRASI FIREBASE ---
  Future<void> _registerUser() async {
    // 1. Validasi Input Kosong
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan Password tidak boleh kosong')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Mulai loading
    });

    try {
      // 2. Kirim data ke Firebase Auth
      UserCredential userCredential = 
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // (Opsional) Update Nama Profil User di Firebase
      await userCredential.user?.updateDisplayName(_nameController.text.trim());

      // 3. Jika Sukses
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi Berhasil! Silakan Login.'),
            backgroundColor: kPrimaryColor,
          ),
        );
        Navigator.pop(context); // Kembali ke layar sebelumnya (Login)
      }

    } on FirebaseAuthException catch (e) {
      // 4. Jika Gagal (Error Handling)
      String message = "Terjadi kesalahan.";
      if (e.code == 'weak-password') {
        message = "Password terlalu lemah (min. 6 karakter).";
      } else if (e.code == 'email-already-in-use') {
        message = "Email ini sudah terdaftar. Gunakan email lain.";
      } else if (e.code == 'invalid-email') {
        message = "Format email salah.";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      // Selesai loading
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Bersihkan controller agar memori aman
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Buat Akun Baru",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87), // Panah back hitam
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Mulai Belanja Hemat",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF202E2E),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Lengkapi data diri Anda di bawah ini.",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 32),

            // INPUT NAMA (Opsional tapi bagus untuk profil)
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Nama Lengkap",
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // INPUT EMAIL
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // INPUT PASSWORD
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible, // Bisa diintip
              decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // TOMBOL DAFTAR
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _registerUser, // Disable jika loading
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Daftar Sekarang",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}