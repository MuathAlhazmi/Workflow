import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:intl/intl.dart';

addNotificationChat(url, type, content, List<String> targetUsers, name) {
  FirebaseFirestore.instance.collection('Notifications').doc().set({
    'date': DateFormat(DateFormat.YEAR_MONTH_DAY, 'ar').format(DateTime.now()),
    'type': type,
    'read': false,
    'imageURL': url == '' ? null : url,
    'targetUsers': targetUsers,
    'content': content,
    'accepted': false,
    'name': name,
    'userId': FirebaseAuth.instance.currentUser!.uid,
  });
}

addNotificationToDo(url, type, content, String id) {
  FirebaseFirestore.instance.collection('Notifications').doc().set({
    'date': DateFormat(DateFormat.YEAR_MONTH_DAY, 'ar').format(DateTime.now()),
    'type': type,
    'read': false,
    'imageURL': url == '' ? null : url,
    'userId': FirebaseAuth.instance.currentUser!.uid,
    'content': content,
    'id': id,
  });
}
