import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_details_page.dart'; // Import your chat detail page
import 'package:g_chat/pages/welcome_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  static const _gradientColors = [Color(0xFF000000), Color(0xFF343434)];
  static const _textColor = Colors.white;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ChatListPage(), // Chat list page
    const GroupsPage(),
    const ProfilePage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: DashboardScreen._gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom header bar
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Center(
                      child: Text(
                        'G Chat',
                        style: TextStyle(
                          color: DashboardScreen._textColor,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.add, color: DashboardScreen._textColor),
                        onPressed: () {
                          // Show popup with 3 options
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.grey[800],
                                title: const Text(
                                  'Choose an Option',
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // New Chat Option
                                    ListTile(
                                      leading: const Icon(Icons.chat, color: Colors.white),
                                      title: const Text(
                                        'New Chat',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onTap: () {
                                        // Handle New Chat option
                                        Navigator.of(context).pop();
                                        print('New Chat selected');
                                      },
                                    ),
                                    // Add Contacts Option
                                    ListTile(
                                      leading: const Icon(Icons.person_add, color: Colors.white),
                                      title: const Text(
                                        'Add Contacts',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onTap: () {
                                        // Handle Add Contacts option
                                        Navigator.of(context).pop();
                                        print('Add Contacts selected');
                                      },
                                    ),
                                    // Scan Option
                                    ListTile(
                                      leading: const Icon(Icons.camera_alt, color: Colors.white),
                                      title: const Text(
                                        'Scan',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onTap: () {
                                        // Handle Scan option
                                        Navigator.of(context).pop();
                                        print('Scan selected');
                                      },
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close the popup
                                    },
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(
                color: Colors.white24,
                thickness: 2,
                height: 0,
              ),

              // Expanded page content below header
              Expanded(child: _pages[_currentIndex]),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Groups'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class ChatListPage extends StatelessWidget {
  const ChatListPage({Key? key}) : super(key: key);

  // Fetch users from Firestore, excluding the current user
  Future<List<QueryDocumentSnapshot>> fetchUsers() async {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid; // Get current user's UID

    if (currentUserUid == null) {
      throw Exception('User is not authenticated');
    }

    final collection = FirebaseFirestore.instance.collection('users');
    final snapshot = await collection.get(); // Fetch all documents in the collection

    // Filter out the current user
    return snapshot.docs.where((doc) => doc.id != currentUserUid).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QueryDocumentSnapshot>>(
      future: fetchUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.teal),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No users found', style: TextStyle(color: Colors.white)),
          );
        }

        final users = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final userData = user.data() as Map<String, dynamic>;

            return Card(
              color: Colors.grey[900],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal,
                  backgroundImage: userData['profile_image'] != null
                      ? NetworkImage(userData['profile_image'])
                      : null,
                  child: userData['profile_image'] == null
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                title: Text(
                  '${userData['first_name'] ?? 'Unknown'} ${userData['last_name'] ?? ''}',
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Tap to chat',
                  style: const TextStyle(color: Colors.white70),
                ),
                onTap: () {
                  // Navigate to ChatDetailPage with the user's name and UID
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailPage(
                        chatName: '${userData['first_name']} ${userData['last_name']}',
                        userId: user.id, // Pass the user's UID to the chat detail page
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class GroupsPage extends StatelessWidget {
  const GroupsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Groups Page", style: TextStyle(color: Colors.white)),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Profile Page", style: TextStyle(color: Colors.white)),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  // Logout function (same as your reference)
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut(); // Firebase logout

    // Optional: Clear session data (if using SharedPreferences)
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');

    // Redirect to WelcomeScreen and clear navigation stack
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Settings",
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
          const SizedBox(height: 30),
          // Logout Button
          ElevatedButton(
            onPressed: () => _logout(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[800], // Red for logout action
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
