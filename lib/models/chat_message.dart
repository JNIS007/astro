import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';

enum MessageType {
  TEXT,
  IMAGE,
  UNKNOWN,
}

class ChatMessage {
  final String chatId;
  final bool isSeen;
  final String lastMessage;
  final String receiverId;
  final int updatedAt;
  final String senderID;
  final MessageType type;
  final String content;
  final DateTime sentTime;

  ChatMessage({
    required this.chatId,
    required this.isSeen,
    required this.lastMessage,
    required this.receiverId,
    required this.updatedAt,
    required this.senderID,
    required this.type,
    required this.content,
    required this.sentTime,
  });

  factory ChatMessage.fromJSON(Map<String, dynamic> json) {
    MessageType messageType;
    switch (json["type"]) {
      case "text":
        messageType = MessageType.TEXT;
        break;
      case "image":
        messageType = MessageType.IMAGE;
        break;
      default:
        messageType = MessageType.UNKNOWN;
    }
    return ChatMessage(
      chatId: json["chatId"],
      isSeen: json["isSeen"],
      lastMessage: json["lastMessage"],
      receiverId: json["receiverId"],
      updatedAt: json["updatedAt"],
      senderID: json["sender_id"],
      type: messageType,
      content: json["content"],
      sentTime: (json["sent_time"] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    String messageType;
    switch (type) {
      case MessageType.TEXT:
        messageType = "text";
        break;
      case MessageType.IMAGE:
        messageType = "image";
        break;
      default:
        messageType = "unknown";
    }
    return {
      "chatId": chatId,
      "isSeen": isSeen,
      "lastMessage": lastMessage,
      "receiverId": receiverId,
      "updatedAt": updatedAt,
      "sender_id": senderID,
      "type": messageType,
      "content": content,
      "sent_time": Timestamp.fromDate(sentTime),
    };
  }
}

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
          FirebaseFirestore.instance
              .collection('userchats')
              .doc(widget.currentUserEmail)
              .collection('chats')
              .add(newMessage);
        } catch (e) {
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
      String senderId = widget.currentUserEmail;
      String receiverId = widget.recipientEmail;
      DateTime now = DateTime.now();

      String chatId =
          FirebaseFirestore.instance.collection('userchats').doc().id;
      ChatMessage newMessage = ChatMessage(
        chatId: chatId,
        isSeen: false,
        lastMessage: messageText,
        receiverId: receiverId,
        updatedAt: now.millisecondsSinceEpoch,
        senderID: senderId,
        type: MessageType.TEXT,
        content: messageText,
        sentTime: now,
      );

      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Update userchats collection
      FirebaseFirestore.instance
          .collection('userchats')
          .doc(userId)
          .collection('chats')
          .doc(chatId)
          .set(newMessage.toJson());

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
                  .collection('userchats')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('chats')
                  .orderBy('updatedAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var messages = snapshot.data!.docs.map((doc) {
                  return ChatMessage.fromJSON(
                      doc.data() as Map<String, dynamic>);
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    ChatMessage message = messages[index];
                    bool isMe = message.senderID == widget.currentUserEmail;
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
                              message.content,
                              style: const TextStyle(fontSize: 16.0),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              _formatTimestamp(
                                  message.sentTime.millisecondsSinceEpoch),
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
