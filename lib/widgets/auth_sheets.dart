// lib/widgets/auth_sheets.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../main.dart';
import '../screens/main_app_screen.dart';

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
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold, color: kTextColor),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: kTextColor, size: 28),
        ),
      ],
    );
  }
}

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
  SIGN IN (LOGIN) – LARAVEL
  =============================================================
*/
class SignInSheetContent extends StatefulWidget {
  const SignInSheetContent({super.key});

  @override
  State<SignInSheetContent> createState() => _SignInSheetContentState();
}

class _SignInSheetContentState extends State<SignInSheetContent> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleSignIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email dan Password harus diisi")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final response = await ApiService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);

      if (response['token'] != null) {
        Navigator.pop(context);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainAppScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Login gagal'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
          controller: _passwordController,
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : const Text('SIGN IN',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        const SizedBox(height: 16),

        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
            showAuthSheet(context, const SignUpSheetContent());
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            side: const BorderSide(color: kPrimaryColor),
          ),
          child: const Text(
            'CREATE AN ACCOUNT',
            style:
                TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

/*
  =============================================================
  SIGN UP (REGISTER) – LARAVEL
  =============================================================
*/
class SignUpSheetContent extends StatefulWidget {
  const SignUpSheetContent({super.key});

  @override
  State<SignUpSheetContent> createState() => _SignUpSheetContentState();
}

class _SignUpSheetContentState extends State<SignUpSheetContent> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleSignUp() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon lengkapi semua data")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final response = await ApiService.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);

      if (response['token'] != null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Akun berhasil dibuat! Silakan Login."),
            backgroundColor: kPrimaryColor,
          ),
        );
        showAuthSheet(context, const SignInSheetContent());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Registrasi gagal'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AuthSheetHeader(title: 'Create your account'),
        const SizedBox(height: 24),

        CustomAuthField(
            hintText: 'Full Name', controller: _nameController),
        const SizedBox(height: 16),
        CustomAuthField(
            hintText: 'Email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 16),
        CustomAuthField(
            hintText: 'Password',
            isPassword: true,
            controller: _passwordController),
        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: _isLoading ? null : _handleSignUp,
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : const Text('CREATE AN ACCOUNT',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ],
    );
  }
}

/*
  =============================================================
  FORGOT PASSWORD
  =============================================================
*/
class ForgotPassSheetContent extends StatefulWidget {
  const ForgotPassSheetContent({super.key});

  @override
  State<ForgotPassSheetContent> createState() =>
      _ForgotPassSheetContentState();
}

class _ForgotPassSheetContentState extends State<ForgotPassSheetContent> {
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AuthSheetHeader(title: 'Forget Password'),
        const SizedBox(height: 24),
        CustomAuthField(
            hintText: 'Enter your email', controller: _emailController),
        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    "Fitur reset password dikelola oleh admin."),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('SUBMIT',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ],
    );
  }
}
