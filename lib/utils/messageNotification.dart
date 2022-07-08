import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:http/http.dart' as http;

void Notify() async {
  if (!Platform.isMacOS) {
    // local notification
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 10,
            channelKey: 'basic_channel',
            title: 'Simple Notification',
            body: 'Simple body',
            bigPicture: 'assets://images/protocoderlogo.png'));
  }
}

class Api {
  final HttpClient httpClient = HttpClient();
  final String fcmUrl = 'https://fcm.googleapis.com/fcm/send';
  final fcmKey =
      "AAAAlQ2tB5o:APA91bE9PDK_mpdpJby5HaViBVFjjvjbwwe-ySQW2Cluu_2Et0nhFMEqFgaj_fn8qno4QW_kEPL4TE5Bru5w063gCixMEctlaaWdWFzf4We7ax0wRabDVtwhDbT4ccCTJRd0U0VVKkpr";

  void sendFcm(String title, String body, String fcmToken, room) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$fcmKey'
    };
    var request = http.Request('POST', Uri.parse(fcmUrl));
    request.body =
        '''{"to":"$fcmToken","priority":"high","notification":{"title":"$title","body":"$body","sound": "default"}}''';
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }
}
