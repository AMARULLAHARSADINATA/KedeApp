// lib/widgets/auth_sheets.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import '../main.dart'; 
import '../screens/main_app_screen.dart'; // Import Halaman Utama

/*
  =============================================================
  WIDGET UTAMA (REUSABLE)
  =============================================================
*/

void showAuthSheet(BuildContext context, Widget child) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.85, 
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.only(
                left: 24, 
                right: 24, 
                top: 24,
                // Padding bawah dinamis agar tidak tertutup keyboard
                bottom: MediaQuery.of(context).viewInsets.bottom + 24
              ),
              child: child,
            ),
          );
        },
      );
    },
  );
}

class AuthSheetHeader extends StatelessWidget {
  final String title;
  const AuthSheetHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold, color: kTextColor
        )),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: kTextColor, size: 28),
        ),
      ],
    );
  }
}

// UPDATE: Ditambahkan controller agar bisa menerima inputan user
class CustomAuthField extends StatelessWidget {
  final String hintText;
  final bool isPassword;
  final TextEditingController? controller; 
  final TextInputType? keyboardType;

  const CustomAuthField({
    super.key,
    required this.hintText,
    this.isPassword = false,
    this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller, 
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: kTextLightColor),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    );
  }
}

/*
  =============================================================
  KONTEN: SIGN IN (LOGIN)
  =============================================================
*/
class SignInSheetContent extends StatefulWidget {
  const SignInSheetContent({super.key});

  @override
  State<SignInSheetContent> createState() => _SignInSheetContentState();
}

class _SignInSheetContentState extends State<SignInSheetContent> {
  // Controller untuk membaca teks inputan
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // --- LOGIKA LOGIN FIREBASE ---
  Future<void> _handleSignIn() async {
    // 1. Validasi Input Kosong
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email dan Password harus diisi")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Kirim data ke Firebase
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context); // Tutup Sheet Login
        
        // 3. SUKSES: PINDAH KE HALAMAN UTAMA (MainAppScreen)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainAppScreen()), 
        );
      }
    } on FirebaseAuthException catch (e) {
      // 4. Gagal (Error Handling)
      if (mounted) {
        String msg = "Login Gagal";
        if (e.code == 'user-not-found') msg = "Email tidak terdaftar";
        else if (e.code == 'wrong-password') msg = "Password salah";
        else if (e.code == 'invalid-email') msg = "Format email salah";
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AuthSheetHeader(title: 'Sign In'),
        const SizedBox(height: 24),
        
        CustomAuthField(
          hintText: 'Email', 
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        CustomAuthField(
          hintText: 'Password', 
          isPassword: true, 
          controller: _passwordController
        ),
        const SizedBox(height: 16),
        
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
              showAuthSheet(context, const ForgotPassSheetContent());
            },
            child: const Text('Forgot Password?',
                style: TextStyle(color: kPrimaryColor)),
          ),
        ),
        const SizedBox(height: 24),
        
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSignIn,
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('SIGN IN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        const SizedBox(height: 16),
        
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
            showAuthSheet(context, const SignUpSheetContent());
          },
          style: OutlinedButton.styleFrom(
             padding: const EdgeInsets.symmetric(vertical: 16),
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
             side: const BorderSide(color: kPrimaryColor),
          ),
          child: const Text('CREATE AN ACCOUNT', style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

/*
  =============================================================
  KONTEN: SIGN UP (REGISTER)
  =============================================================
*/
class SignUpSheetContent extends StatefulWidget {
  const SignUpSheetContent({super.key});

  @override
  State<SignUpSheetContent> createState() => _SignUpSheetContentState();
}

class _SignUpSheetContentState extends State<SignUpSheetContent> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController(); 
  bool _isLoading = false;

  Future<void> _handleSignUp() async {
     if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon lengkapi semua data")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (_nameController.text.isNotEmpty) {
        await userCred.user?.updateDisplayName(_nameController.text.trim());
      }

      if (mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Akun berhasil dibuat! Silakan Login."), backgroundColor: kPrimaryColor),
        );
        showAuthSheet(context, const SignInSheetContent());
      }

    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String msg = "Registrasi Gagal";
        if (e.code == 'email-already-in-use') msg = "Email sudah terdaftar";
        else if (e.code == 'weak-password') msg = "Password terlalu lemah (min 6 karakter)";
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AuthSheetHeader(title: 'Create your account'),
        const SizedBox(height: 24),
        
        CustomAuthField(hintText: 'Full Name', controller: _nameController),
        const SizedBox(height: 16),
        CustomAuthField(hintText: 'Email', controller: _emailController, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 16),
        CustomAuthField(hintText: 'Password', isPassword: true, controller: _passwordController),
        const SizedBox(height: 24),
        
        Text.rich(
          TextSpan(
            text: 'By tapping Sign up you accept all ',
            style: Theme.of(context).textTheme.bodyMedium,
            children: const [
              TextSpan(
                text: 'terms and condition',
                style: TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSignUp,
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('CREATE AN ACCOUNT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ],
    );
  }
}

/*
  =============================================================
  KONTEN: FORGOT PASSWORD
  =============================================================
*/
class ForgotPassSheetContent extends StatefulWidget {
  const ForgotPassSheetContent({super.key});

  @override
  State<ForgotPassSheetContent> createState() => _ForgotPassSheetContentState();
}

class _ForgotPassSheetContentState extends State<ForgotPassSheetContent> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleResetPass() async {
    if (_emailController.text.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Link reset password telah dikirim ke email Anda.")),
        );
        Navigator.pop(context); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengirim email: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AuthSheetHeader(title: 'Forget Password'),
        const SizedBox(height: 24),
        CustomAuthField(hintText: 'Enter your email', controller: _emailController),
        const SizedBox(height: 24),
        
        ElevatedButton(
          onPressed: _isLoading ? null : _handleResetPass,
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('SUBMIT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        const SizedBox(height: 24),
        
        Align(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
              showAuthSheet(context, const SignInSheetContent());
            },
            child: const Text.rich(
              TextSpan(
                text: 'Sign in to your registered account ',
                style: TextStyle(color: kTextLightColor),
                children: [
                  TextSpan(
                    text: 'Login here',
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}