import 'package:cloud_firestore/cloud_firestore.dart';

class ChatUser {
  final String uid;
  final String name;
  final String email;
  final String imageURL;
  final DateTime lastActive;
  final String dateOfBirth;
  final String phone;

  ChatUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.imageURL,
    required this.lastActive,
    required this.dateOfBirth,
    required this.phone,
  });

  factory ChatUser.fromJSON(Map<String, dynamic> json) {
    return ChatUser(
      uid: json["uid"],
      name: json["name"],
      email: json["email"],
      imageURL: json["image"],
      lastActive: (json["last_active"] as Timestamp).toDate(),
      dateOfBirth: json["dateOfBirth"],
      phone: json["phone"],
    );
  }

  factory ChatUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatUser(
      uid: doc.id,
      name: data['name'],
      email: data['email'],
      imageURL: data['image'],
      lastActive: (data['last_active'] as Timestamp).toDate(),
      dateOfBirth: data['dateOfBirth'],
      phone: data['phone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "image": imageURL,
      "last_active": Timestamp.fromDate(lastActive),
      "dateOfBirth": dateOfBirth,
      "phone": phone,
    };
  }

  String lastDayActive() {
    return "${lastActive.month}/${lastActive.day}/${lastActive.year}";
  }

  bool wasRecentlyActive() {
    return DateTime.now().difference(lastActive).inHours < 2;
  }
}
