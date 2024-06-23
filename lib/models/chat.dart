import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_user.dart';
import '../models/chat_message.dart';

class Chat {
  final String uid;
  final String currentUserUid;
  final bool activity;
  final bool group;
  final List<ChatUser> members;
  List<ChatMessage> messages;

  Chat({
    required this.uid,
    required this.currentUserUid,
    required this.members,
    required this.messages,
    required this.activity,
    required this.group,
  });

  List<ChatUser> get recipients {
    return members.where((member) => member.uid != currentUserUid).toList();
  }

  String title() {
    return !group
        ? recipients.isNotEmpty
            ? recipients.first.name
            : 'No recipients'
        : recipients.map((user) => user.name).join(", ");
  }

  String imageURL() {
    return !group
        ? recipients.isNotEmpty
            ? recipients.first.imageURL
            : 'https://via.placeholder.com/150'
        : "https://e7.pngegg.com/pngimages/380/670/png-clipart-group-chat-logo-blue-area-text-symbol-metroui-apps-live-messenger-alt-2-blue-text.png";
  }

  static Future<Chat> fromFirestore(String uid, String currentUserUid) async {
    // Fetch the chat document
    DocumentSnapshot chatSnapshot = await FirebaseFirestore.instance
        .collection('userchats')
        .doc(currentUserUid)
        .collection('chats')
        .doc(uid)
        .get();

    if (!chatSnapshot.exists) {
      throw Exception("Chat not found");
    }

    // Parse the chat document
    Map<String, dynamic> chatData = chatSnapshot.data() as Map<String, dynamic>;

    // Fetch the members of the chat
    List<ChatUser> members = [];
    List<dynamic> memberUids = chatData['members'] as List<dynamic>;
    for (String memberUid in memberUids) {
      DocumentSnapshot memberSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(memberUid)
          .get();
      if (memberSnapshot.exists) {
        members.add(ChatUser.fromFirestore(memberSnapshot));
      }
    }

    // Fetch the messages of the chat
    List<ChatMessage> messages = [];
    QuerySnapshot messageSnapshot = await FirebaseFirestore.instance
        .collection('userchats')
        .doc(currentUserUid)
        .collection('chats')
        .doc(uid)
        .collection('messages')
        .orderBy('sent_time', descending: true)
        .get();

    for (DocumentSnapshot messageDoc in messageSnapshot.docs) {
      messages
          .add(ChatMessage.fromJSON(messageDoc.data() as Map<String, dynamic>));
    }

    return Chat(
      uid: uid,
      currentUserUid: currentUserUid,
      members: members,
      messages: messages,
      activity: chatData['activity'],
      group: chatData['group'],
    );
  }
}
