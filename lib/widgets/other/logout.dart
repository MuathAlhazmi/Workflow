import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:workflow/widgets/other/snackbar.dart';

class LogOutPage extends StatefulWidget {
  const LogOutPage({Key? key}) : super(key: key);

  @override
  _LogOutPageState createState() => _LogOutPageState();
}

class _LogOutPageState extends State<LogOutPage> {
  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.signOut();
    snackBarWidget(context, 'تم تسجيل الخروج بنجاج', CupertinoIcons.check_mark,
        Colors.white);

    return Container();
  }
}
