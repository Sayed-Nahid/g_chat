import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:g_chat/pages/profile_set_screen.dart';

class EmailVerificationWaitingScreen extends StatefulWidget {
  const EmailVerificationWaitingScreen({Key? key}) : super(key: key);

  @override
  State<EmailVerificationWaitingScreen> createState() =>
      _EmailVerificationWaitingScreenState();
}

class _EmailVerificationWaitingScreenState
    extends State<EmailVerificationWaitingScreen> {
  late Timer _checkTimer;
  Timer? _cooldownTimer;
  late User _user;

  bool canResend = true;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _startCheckingEmailVerified();
  }

  void _startCheckingEmailVerified() {
    _checkTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await _user.reload();
      _user = FirebaseAuth.instance.currentUser!;
      if (_user.emailVerified) {
        _checkTimer.cancel();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ProfileSetScreen()),
          );
        }
      }
    });
  }

  void _startCooldown() {
    setState(() {
      canResend = false;
      _secondsRemaining = 30; // cooldown time
    });

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 1) {
        timer.cancel();
        if (mounted) {
          setState(() {
            canResend = true;
            _secondsRemaining = 0;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _checkTimer.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _resendVerificationEmail() async {
    await FirebaseAuth.instance.currentUser?.reload();
    _user = FirebaseAuth.instance.currentUser!;

    try {
      await _user.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email resent')),
        );
        _startCooldown();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF000000), Color(0xFF343434)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 150,
                  height: 150,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.error, color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Verify Your Email',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'We’ve sent a verification link to your email. Please verify and this screen will automatically continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: canResend ? _resendVerificationEmail : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF81D8D0),
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                  ),
                  child: Text(
                    canResend
                        ? 'Resend Email'
                        : 'Wait $_secondsRemaining sec',
                    style: const TextStyle(fontSize: 16),
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
