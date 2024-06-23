import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';

class ChatScreen extends StatelessWidget {
  final String currentUserId;
  final String adminEmail;
  final String recipientEmail;
  final String recipientUsername;

  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.adminEmail,
    required this.recipientEmail,
    required this.recipientUsername,
  });

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser != null) {
      return Scaffold(
        backgroundColor: Colors.cyan[100],
        appBar: AppBar(
          title: const Text(
            'Astrologer',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // Handle drawer action
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.payment),
              onPressed: () {
                // Handle payment action
              },
            ),
          ],
        ),
        body: ChatMessages(
          currentUserEmail: currentUserId,
          adminEmail: adminEmail,
          recipientEmail: recipientEmail,
        ),
      );
    } else {
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, 'login');
            },
            child: const Text('Login to access chat'),
          ),
        ),
      );
    }
  }
}

class ChatMessages extends StatefulWidget {
  final String currentUserEmail;
  final String adminEmail;
  final String recipientEmail;

  const ChatMessages({
    super.key,
    required this.currentUserEmail,
    required this.adminEmail,
    required this.recipientEmail,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ChatMessagesState createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  final TextEditingController _messageController = TextEditingController();
  late IOWebSocketChannel _channel;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _channel = IOWebSocketChannel.connect("wss://ws.ifelse.io/");
    _channel.stream.listen((message) {
      setState(() {
        try {
          Map<String, dynamic> newMessage = jsonDecode(message);
          FirebaseFirestore.instance.collection('messages').add(newMessage);
        } catch (e) {
          // ignore: avoid_print
          print('Error decoding message: $e');
        }
      });
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage(String messageText) {
    if (_formKey.currentState!.validate()) {
      String senderEmail = widget.currentUserEmail;

      Map<String, dynamic> newMessage = {
        'text': messageText,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'sender': senderEmail,
        'recipient': widget.recipientEmail,
      };

      _channel.sink.add(jsonEncode(newMessage));
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var messages = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var messageData =
                        messages[index].data() as Map<String, dynamic>;
                    bool isMe =
                        messageData['sender'] == widget.currentUserEmail;
                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              messageData['text'] ?? '',
                              style: const TextStyle(fontSize: 16.0),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              _formatTimestamp(messageData['timestamp']),
                              style: TextStyle(
                                  fontSize: 12.0, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _messageController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a message';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    _sendMessage(_messageController.text.trim());
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16.0),
                    shape: const CircleBorder(),
                  ),
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(int timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var formattedDate =
        "${date.hour}:${date.minute < 10 ? '0' : ''}${date.minute}";
    return formattedDate;
  }
}
