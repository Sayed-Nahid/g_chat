import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For storing session
import 'package:g_chat/pages/welcome_screen.dart';  // Your WelcomeScreen

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Logout function to clear the session and redirect to WelcomeScreen
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut(); // Firebase logout

    // Remove user session data from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId'); // Clear session

    // Redirect to the WelcomeScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get current user info for the welcome message
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome, ${user?.displayName ?? user?.email ?? "User"}!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ) ??
                      const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => _logout(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    backgroundColor: Colors.blue[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Logout',
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
}
