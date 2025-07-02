import 'package:flutter/material.dart';

class ChatDetailPage extends StatefulWidget {
  final String chatName;
  final String userId;
  final String? profileImageUrl; // Add profile image URL

  const ChatDetailPage({
    Key? key,
    required this.chatName,
    required this.userId,
    this.profileImageUrl,
  }) : super(key: key);

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0C0C), // Match dashboard background
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F), // Match dashboard theme
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.teal, // Background color if no image is loaded
              child: widget.profileImageUrl != null
                  ? Image.network(
                widget.profileImageUrl!,
                fit: BoxFit.cover, // Ensures the image covers the CircleAvatar
                errorBuilder: (context, error, stackTrace) {
                  print('Failed to load profile image: $error');
                  return const Icon(Icons.person, color: Colors.white);
                },
              )
                  : const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 5), // Reduced space
            Flexible(
              child: Text(
                widget.chatName,
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis, // Truncate if too long
              ),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min, // Minimize row width
            children: [
              IconButton(
                icon: const Icon(Icons.videocam, color: Colors.white),
                onPressed: () {
                  // Add video call functionality
                  print('Video call selected for ${widget.chatName}');
                },
              ),
              IconButton(
                icon: const Icon(Icons.call, color: Colors.white),
                onPressed: () {
                  // Add voice call functionality
                  print('Voice call selected for ${widget.chatName}');
                },
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {
                  // Add more options (e.g., mute, block, etc.)
                  print('More options selected for ${widget.chatName}');
                },
              ),
            ],
          ),
        ],
      ),
      body: Column(
          children: [
      // Chat messages
      Expanded(
      child: ListView.builder(
      padding: const EdgeInsets.all(16),
      reverse: true,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[_messages.length - 1 - index];
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
        crossAxisAlignment:
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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

  // Message input field
  Container(
  padding: const EdgeInsets.all(8),
  color: const Color(0xFF1F1F1F), // Match dashboard theme
  child: Row(
  children: [
  IconButton(
  icon: const Icon(Icons.emoji_emotions, color: Colors.white),
  onPressed: () {
  // Add emoji picker functionality
  print('Emoji picker selected');
  },
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
  icon: const Icon(Icons.send, color: Colors.teal), // Match dashboard accent color
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
