import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatDetailPage extends StatefulWidget {
  final String chatName;
  final String userId;

  const ChatDetailPage({
    Key? key,
    required this.chatName,
    required this.userId,
  }) : super(key: key);

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (doc.exists) {
        setState(() {
          _userData = doc.data()!;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        _messages.add({
          "text": _messageController.text,
          "sender": "You",
          "time": "${TimeOfDay.now().hour}:${TimeOfDay.now().minute}",
        });
        _messageController.clear();
      });
    }
  }

  // New: Function to handle three-dot menu actions
  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F1F1F),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.block, color: Colors.white),
                title: const Text('Block User', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  print('Block ${_userData?['first_name'] ?? 'User'}');
                },
              ),
              ListTile(
                leading: const Icon(Icons.report, color: Colors.white),
                title: const Text('Report', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  print('Report ${_userData?['first_name'] ?? 'User'}');
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.white),
                title: const Text('Clear Chat', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  print('Clear chat with ${_userData?['first_name'] ?? 'User'}');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0C0C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.teal,
              backgroundImage: _userData?['profile_image'] != null
                  ? NetworkImage(_userData!['profile_image'])
                  : null,
              child: _userData?['profile_image'] == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _userData != null
                    ? "${_userData!['first_name'] ?? 'Unknown'} ${_userData!['last_name'] ?? ''}"
                    : widget.chatName,
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Video call button
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.white),
            onPressed: () {
              print('Video call with ${_userData?['first_name'] ?? 'User'}');
            },
          ),
          // Voice call button
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            onPressed: () {
              print('Voice call with ${_userData?['first_name'] ?? 'User'}');
            },
          ),
          // Three-dot menu
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: _showMoreOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message["sender"] == "You";
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF005C4B) : const Color(0xFF1F2C33),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          message["text"]!,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message["time"]!,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: const Color(0xFF1F1F1F),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.emoji_emotions, color: Colors.white),
                  onPressed: () => print('Emoji picker selected'),
                ),
                Flexible(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Type a message",
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.teal),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}