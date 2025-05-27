import 'package:flutter/material.dart';
import 'package:g_chat/pages/welcome_screen.dart';

import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToWelcomeScreen();
  }

  Future<void> _navigateToWelcomeScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const GradientBackground(child: WelcomeScreen()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          // Constrain logo size while preventing overflow
          constraints: const BoxConstraints(
            maxWidth: 200,
            maxHeight: 200,
          ),
          child: Image.asset(
            'assets/images/splash_logo.png',
            fit: BoxFit.contain, // Show full logo without cropping
            errorBuilder: (context, error, stackTrace) => const FlutterLogo(),
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}