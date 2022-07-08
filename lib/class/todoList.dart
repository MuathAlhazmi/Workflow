import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:workflow/utils/messageNotification.dart';

class TodoClass {
  TodoClass({
    required this.room,
    required this.title,
    required this.priority,
    required this.desc,
    required this.dateTime,
    this.isCompleted = false,
  });
  final types.Room room;
  final String title;
  final String desc;
  final String priority;
  bool isCompleted;

  final String dateTime;
  Future addTodo() async {
    var todol = await FirebaseFirestore.instance.collection('Todo').add({
      'isCompleted': isCompleted,
      'priority': priority,
      'createdAt': FieldValue.serverTimestamp(),
      'due': dateTime,
      'done': false,
      'title': title,
      'room': room.name,
      'desc': desc,
      'admin': FirebaseAuth.instance.currentUser!.uid,
      'userIds': room.users.map((e) => e.id).toList(),
    });
    todol.collection('SubTask').add({
      'title': 'مثال',
      'isCompleted': false,
    });
    todol.update({
      'id': todol.id,
    });
    return todol.id;
  }

  Future notifyTodo() async {
    var newToken;
    List users = room.users
        .map((e) => e.id)
        .toList()
        .where((element) => element == FirebaseAuth.instance.currentUser!.uid)
        .toList();
    users.forEach((element) async {
      var docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(element)
          .get();
      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data()!;

        newToken = data['metadata']['token'];
      }

      Api().sendFcm('مهمة', 'لديك مهمة جديدة', newToken, room);
    });
  }
}

class SubTask {
  String title;
  bool isCompleted;

  SubTask({
    required this.title,
    this.isCompleted = false,
  });

  factory SubTask.fromJson(Map<String, dynamic> json) => SubTask(
        title: json["title"],
        isCompleted: json["isCompleted"],
      );

  Map<String, dynamic> toMap() => {
        "title": title,
        "isCompleted": isCompleted,
      };

  SubTask.fromMap(Map<String, dynamic> map)
      : title = map["title"],
        isCompleted = map["isCompleted"];
}
