import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:g_chat/pages/dashboard_screen.dart';
import 'package:g_chat/pages/signup_screen.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import 'forgot_password_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _obscurePassword = true;
  bool isEmailSelected = true;
  bool showOtpField = false;
  bool isVerifying = false;
  String? _verificationId;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _sendOtp() async {
    final phone = _phoneController.text.trim();

    if (!RegExp(r'^\+?[0-9]{10,13}$').hasMatch(phone)) {
      _showError("Invalid phone number");
      return;
    }

    setState(() => isVerifying = true);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          _navigateToHome();
        },
        verificationFailed: (FirebaseAuthException e) {
          _showError("Verification failed: ${e.message}");
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            showOtpField = true;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _showError("OTP send failed: $e");
    } finally {
      setState(() => isVerifying = false);
    }
  }

  void _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (_verificationId == null || otp.isEmpty) {
      _showError("Please enter OTP");
      return;
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      _navigateToHome();
    } catch (e) {
      _showError("Invalid OTP");
    }
  }

  void _emailLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.length < 6) {
      _showError("Please enter valid credentials");
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _navigateToHome();
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Login failed");
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => DashboardScreen()),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

// Replace your build() method with this:

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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 150,
                      height: 150,
                      errorBuilder: (_, __, ___) =>
                      const Icon(Icons.chat, size: 100, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Welcome Back!',
                      style: Theme
                          .of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ) ??
                          const TextStyle(fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                    ),
                    const SizedBox(height: 30),

                    // Fields
                    if (isEmailSelected) ...[
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          labelStyle: const TextStyle(color: Colors.white),
                          hintText: 'example@mail.com',
                          hintStyle: const TextStyle(color: Colors.white54),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Colors.white),
                          hintStyle: const TextStyle(color: Colors.white54),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons
                                  .visibility,
                              color: Colors.white70,
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Align everything to the left
                        children: [
                          // Your Email and Password fields go here...

                          const SizedBox(height: 0),

                          // Forgot Password Text
                          Container(
                            alignment: Alignment.centerLeft,  // Make sure the text is left-aligned
                            child: TextButton(
                              onPressed: () {
                                // Navigate to Forgot Password screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                                );
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,  // Font size for the text
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,  // Remove any extra padding
                              ),
                            ),
                          ),
                        ],
                      )

                    ] else
                      ...[
                        IntlPhoneField(
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            labelStyle: const TextStyle(color: Colors.white),
                            hintText: '1XXXXXXXXX',
                            hintStyle: const TextStyle(color: Colors.white54),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                          ),
                          initialCountryCode: 'BD', // default to Bangladesh
                          dropdownIcon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                          style: const TextStyle(color: Colors.white),
                          onChanged: (phone) {
                            _phoneController.text = phone.completeNumber; // +8801XXXXXXX
                          },
                        ),

                        if (!showOtpField)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: isVerifying ? null : _sendOtp,
                              child: const Text('Send', style: TextStyle(
                                  color: Colors.lightBlueAccent)),
                            ),
                          ),
                        if (showOtpField)
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: TextFormField(
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'OTP Code',
                                labelStyle: const TextStyle(
                                    color: Colors.white),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: Colors.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: Colors.white),
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                      ],

                    const SizedBox(height: 20),

                    // 🔁 Toggle Email/Phone (centered)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isEmailSelected = !isEmailSelected;
                          _emailController.clear();
                          _passwordController.clear();
                          _phoneController.clear();
                          _otpController.clear();
                          showOtpField = false;
                        });
                      },
                      child: Text(
                        isEmailSelected
                            ? 'Use Phone Number Instead'
                            : 'Use Email Instead',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 🔐 Login Button
                    ElevatedButton(
                      onPressed: () {
                        if (isEmailSelected) {
                          _emailLogin();
                        } else if (showOtpField) {
                          _verifyOtp();
                        } else {
                          _sendOtp();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 120, vertical: 18),
                        backgroundColor: const Color(0xFF81D8D0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                          'LOGIN', style: TextStyle(fontSize: 18)),
                    ),

                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SignupScreen()),
                        );
                      },
                      child: const Text(
                        'Don\'t have an account? Sign Up',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
