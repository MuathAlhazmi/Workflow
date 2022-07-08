import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

createUser(String uid, String firstname, String lastname) async {
  await FirebaseChatCore.instance.createUserInFirestore(
    types.User(
      metadata: {
        'id': uid,
        'token': await FirebaseMessaging.instance.getToken(),
      },
      firstName: firstname,
      id: uid, //
      lastName: lastname,
    ),
  );
}
