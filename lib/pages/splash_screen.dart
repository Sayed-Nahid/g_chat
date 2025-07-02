import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:g_chat/pages/dashboard_screen.dart';  // Your home/dashboard screen
import 'package:g_chat/pages/login_screen.dart';     // Your login screen
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
    _checkUserSession(); // Check user session on splash screen
  }

  // Check if the user is logged in
  Future<void> _checkUserSession() async {
    await Future.delayed(const Duration(seconds: 3));

    // Get the current user from Firebase
    User? user = FirebaseAuth.instance.currentUser;

    // If the user is logged in, navigate to the Dashboard
    if (user != null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } else {
      // If no user is logged in, navigate to the WelcomeScreen or LoginScreen
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GradientBackground(child: WelcomeScreen())),
      );
    }
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
