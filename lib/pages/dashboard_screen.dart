import 'package:flutter/material.dart';

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
    const ChatListPage(),
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
                        'Chats',
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
                                        // You can navigate to the New Chat screen or show a form
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
                                        // Navigate to the Add Contacts screen or show contacts
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
                                        // You can open the scanner or QR code reader here
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
                      )

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

  final List<Map<String, String>> dummyChats = const [
    {"name": "Azman", "lastMessage": "Hey there!", "time": "9:00 AM"},
    {"name": "GPT Bot", "lastMessage": "Let’s build your app!", "time": "8:30 AM"},
    {"name": "John Doe", "lastMessage": "I'll call you later.", "time": "Yesterday"},
    {"name": "Flutter Dev", "lastMessage": "We are live!", "time": "2 days ago"},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dummyChats.length,
      itemBuilder: (context, index) {
        final chat = dummyChats[index];
        return Card(
          color: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.teal,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(chat["name"]!, style: const TextStyle(color: Colors.white)),
            subtitle: Text(chat["lastMessage"]!, style: const TextStyle(color: Colors.white70)),
            trailing: Text(chat["time"]!, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            onTap: () {
              // TODO: Open chat detail page
            },
          ),
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

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Settings Page", style: TextStyle(color: Colors.white)),
    );
  }
}
