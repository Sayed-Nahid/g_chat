import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final Map<String, dynamic> receiver;

  ChatScreen({required this.chatId, required this.receiver});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get the current user ID
  String get currentUserId => _auth.currentUser!.uid;

  @override
  void initState() {
    super.initState();
  }

  // Function to send the message
  void _sendMessage() async {
    String text = _controller.text.trim();

    if (text.isNotEmpty) {
      // Add the message to Firestore
      await _firestore.collection('chats').doc(widget.chatId).collection('messages').add({
        'text': text,
        'senderId': currentUserId,
        'receiverId': widget.receiver['uid'],
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'type': 'text', // For now, it's a text message
      });

      // Optionally, update the last message in the chat metadata
      await _firestore.collection('chats').doc(widget.chatId).update({
        'lastMessage': text,
        'lastSenderId': currentUserId,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      // Clear the input field
      _controller.clear();
    }
  }

  // StreamBuilder to listen for messages in real-time
  Stream<QuerySnapshot> _getMessages() {
    return _firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .orderBy('timestamp') // Sort messages by timestamp
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.receiver['firstName']}'),
      ),
      body: Column(
        children: [
          // Message List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getMessages(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No messages yet."));
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index].data() as Map<String, dynamic>;
                    bool isSentByCurrentUser = message['senderId'] == currentUserId;

                    return Align(
                      alignment: isSentByCurrentUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
                        decoration: BoxDecoration(
                          color: isSentByCurrentUser ? Colors.blue : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          message['text'],
                          style: TextStyle(
                            color: isSentByCurrentUser ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Message Input Area
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
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
