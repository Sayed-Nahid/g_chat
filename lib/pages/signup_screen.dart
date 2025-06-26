import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:g_chat/pages/profile_set_screen.dart';
import 'package:g_chat/pages/email_verification_waiting_screen.dart';

import 'login_screen.dart'; // Navigate to this screen after sign-up

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool isPhoneSelected = true;
  String? selectedCountry;
  bool showSendButton = false;
  bool showVerificationField = false;
  bool _isVerifying = false;
  String? _verificationId;

  final Map<String, String> countryCodes = {
    'Bangladesh': '+880',
    'Australia': '+61',
    'USA': '+1',
    'India': '+91',
    'UK': '+44',
  };

  final Map<String, int> countryMinDigits = {
    'Bangladesh': 10,
    'Australia': 9,
    'USA': 10,
    'India': 10,
    'UK': 10,
  };

  late final TextEditingController phoneEmailController;
  late final TextEditingController verificationController;

  @override
  void initState() {
    super.initState();
    selectedCountry = 'Bangladesh';
    phoneEmailController = TextEditingController();
    verificationController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isPhoneSelected && selectedCountry != null && mounted) {
        final code = countryCodes[selectedCountry]!;
        phoneEmailController.text = code;
        phoneEmailController.selection = TextSelection.collapsed(offset: code.length);
      }
    });

    phoneEmailController.addListener(_handleInputChange);
  }

  bool _validatePhone(String phone) {
    if (!phone.startsWith(countryCodes[selectedCountry]!)) return false;
    final digits = phone.substring(countryCodes[selectedCountry]!.length);
    if (!RegExp(r'^\d+$').hasMatch(digits)) return false;
    return digits.length >= (countryMinDigits[selectedCountry] ?? 8);
  }

  bool _validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _handleInputChange() {
    final input = phoneEmailController.text.trim();
    bool isValid;

    if (isPhoneSelected) {
      isValid = _validatePhone(input) &&
          input.length > countryCodes[selectedCountry]!.length;
    } else {
      isValid = _validateEmail(input);
    }

    if (mounted) {
      setState(() {
        showSendButton = isValid;
        if (!showSendButton) showVerificationField = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onSendPressed() async {
    final phone = phoneEmailController.text.trim();

    if (!_validatePhone(phone)) {
      _showError('Enter a valid phone number.');
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          _showError('Phone auto-verified!');
        },
        verificationFailed: (FirebaseAuthException e) {
          _showError('Verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            showVerificationField = true;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _showError('Failed to send OTP: $e');
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  void _onNextPressed() async {
    final input = phoneEmailController.text.trim();
    final code = verificationController.text.trim();

    if (isPhoneSelected) {
      if (!_validatePhone(input)) {
        _showError('Please enter a valid ${selectedCountry} phone number');
        return;
      }

      if (showVerificationField && code.isEmpty) {
        _showError('Please enter verification code');
        return;
      }

      if (_verificationId != null) {
        try {
          PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: _verificationId!,
            smsCode: code,
          );
          await FirebaseAuth.instance.signInWithCredential(credential);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ProfileSetScreen()),
          );
        } catch (e) {
          _showError('Invalid verification code');
        }
      } else {
        _showError('Verification ID is missing. Tap Send again.');
      }
    } else {
      final email = input;
      final password = 'defaultPass123'; // Temporary password for new users

      try {
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = credential.user;

        if (user != null && !user.emailVerified) {
          await user.sendEmailVerification();

          // ✅ Go to email verification waiting screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const EmailVerificationWaitingScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          _showError('Email is already in use');
        } else if (e.code == 'invalid-email') {
          _showError('Invalid email address');
        } else {
          _showError('Signup failed: ${e.message}');
        }
      }
    }
  }

  @override
  void dispose() {
    phoneEmailController.dispose();
    verificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labelText = isPhoneSelected ? 'Phone Number' : 'Email Address';

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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 150,
                  height: 150,
                  errorBuilder: (_, __, ___) => const Icon(Icons.error, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),

                if (isPhoneSelected)
                  DropdownButtonFormField<String>(
                    value: selectedCountry,
                    decoration: InputDecoration(
                      labelText: 'Country/Region',
                      labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    dropdownColor: Colors.grey[900],
                    iconEnabledColor: Colors.white,
                    items: countryCodes.keys.map((country) {
                      return DropdownMenuItem(
                        value: country,
                        child: Text(country, style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null && mounted) {
                        setState(() {
                          selectedCountry = value;
                          if (isPhoneSelected) {
                            phoneEmailController.text = countryCodes[value]!;
                            phoneEmailController.selection =
                                TextSelection.collapsed(offset: countryCodes[value]!.length);
                            _handleInputChange();
                          }
                        });
                      }
                    },
                  ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: phoneEmailController,
                  keyboardType: isPhoneSelected ? TextInputType.phone : TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: labelText,
                    labelStyle: const TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),

                if (showSendButton && isPhoneSelected)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isVerifying ? null : _onSendPressed,
                      child: const Text(
                        'Send',
                        style: TextStyle(color: Colors.lightBlueAccent),
                      ),
                    ),
                  ),

                if (showVerificationField)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: TextFormField(
                      controller: verificationController,
                      decoration: InputDecoration(
                        labelText: 'Verification Code',
                        labelStyle: const TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                    ),
                  ),

                const SizedBox(height: 10),

                TextButton(
                  onPressed: () {
                    if (mounted) {
                      setState(() {
                        isPhoneSelected = !isPhoneSelected;
                        phoneEmailController.clear();
                        verificationController.clear();
                        showSendButton = false;
                        showVerificationField = false;
                        if (isPhoneSelected && selectedCountry != null) {
                          phoneEmailController.text = countryCodes[selectedCountry]!;
                          phoneEmailController.selection = TextSelection.collapsed(
                              offset: countryCodes[selectedCountry]!.length);
                        }
                      });
                    }
                  },
                  child: Text(
                    isPhoneSelected ? 'Use Email Instead' : 'Use Phone Number Instead',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: _onNextPressed,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 18),
                    backgroundColor: const Color(0xFF81D8D0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(fontSize: 18),
                  ),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Already have an account? Sign In',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
