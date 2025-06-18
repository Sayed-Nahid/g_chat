import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:g_chat/pages/profile_set_screen.dart'; // Make sure this path is correct

class SetPasswordScreen extends StatefulWidget {
  const SetPasswordScreen({super.key});

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  void _onConfirmPressed() async {
    final password = passwordController.text.trim();
    final confirmPassword = confirmController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      _showError('Please fill both fields');
    } else if (password.length < 6) {
      _showError('Password must be at least 6 characters');
    } else if (password != confirmPassword) {
      _showError('Passwords do not match');
    } else {
      setState(() => _isLoading = true);
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.updatePassword(password);
          await user.reload();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password set successfully')),
          );

          // 🔁 Navigate to ProfileSetScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ProfileSetScreen()),
          );
        } else {
          _showError('No authenticated user found');
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          _showError('Please log in again to set your password.');
        } else {
          _showError('Failed to set password: ${e.message}');
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF000000), Color(0xFF343434)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 150,
                  height: 150,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.error, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  'Set Password',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),

                TextFormField(
                  controller: passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: _buildInputDecoration('Password', _isPasswordVisible, () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  }),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: confirmController,
                  obscureText: !_isConfirmVisible,
                  decoration: _buildInputDecoration('Confirm Password', _isConfirmVisible, () {
                    setState(() {
                      _isConfirmVisible = !_isConfirmVisible;
                    });
                  }),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 30),

                _isLoading
                    ? const CircularProgressIndicator(color: Colors.cyanAccent)
                    : ElevatedButton(
                  onPressed: _onConfirmPressed,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 18),
                    backgroundColor: const Color(0xFF81D8D0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
      String label,
      bool isVisible,
      VoidCallback toggleVisibility,
      ) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      suffixIcon: IconButton(
        icon: Icon(
          isVisible ? Icons.visibility : Icons.visibility_off,
          color: Colors.white,
        ),
        onPressed: toggleVisibility,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
