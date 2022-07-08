// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    // ignore: missing_enum_constant_in_switch
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAz5n4Th0ekwQf6vdek4jI0MA4AyC15_rY',
    appId: '1:640179570586:web:30a67e5da650954cb09c23',
    messagingSenderId: '640179570586',
    projectId: 'workflow-fc879',
    authDomain: 'workflow-fc879.firebaseapp.com',
    storageBucket: 'workflow-fc879.appspot.com',
    measurementId: 'G-9XWVGH3E5D',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDfmzlL3V62Wpsc6ApwD0bPM7aaV5hMGvA',
    appId: '1:640179570586:android:e3be1137cc7d000bb09c23',
    messagingSenderId: '640179570586',
    projectId: 'workflow-fc879',
    storageBucket: 'workflow-fc879.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB2Hn_MgErgsBfBkSze6UD-PxCL1Rq8OAo',
    appId: '1:640179570586:ios:539fa4b5d0bac3c1b09c23',
    messagingSenderId: '640179570586',
    projectId: 'workflow-fc879',
    storageBucket: 'workflow-fc879.appspot.com',
    iosClientId: '640179570586-scnhcaqccrtsplr8tv4971abffpo6p8s.apps.googleusercontent.com',
    iosBundleId: 'com.muath.workflow',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB2Hn_MgErgsBfBkSze6UD-PxCL1Rq8OAo',
    appId: '1:640179570586:ios:539fa4b5d0bac3c1b09c23',
    messagingSenderId: '640179570586',
    projectId: 'workflow-fc879',
    storageBucket: 'workflow-fc879.appspot.com',
    iosClientId: '640179570586-scnhcaqccrtsplr8tv4971abffpo6p8s.apps.googleusercontent.com',
    iosBundleId: 'com.muath.workflow',
  );
}
