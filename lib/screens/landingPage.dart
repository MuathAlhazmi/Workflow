import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:workflow/screens/login.dart';
import 'package:workflow/theme/colors.dart';

import '../widgets/other/snackbar.dart';

class LandingPage extends StatefulWidget {
  final bool signingout;
  const LandingPage({required this.signingout});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  signOut() {
    FirebaseAuth.instance.signOut();
    snackBarWidget(context, 'تم تسجيل الخروج بنجاج', CupertinoIcons.check_mark,
        Colors.white);
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (widget.signingout == true) {
        signOut();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        heroTag: 'todotag',
        backgroundColor: fillColor,
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SignUp()));
        },
        child: Icon(Icons.account_circle_rounded, color: mainColor),
      ),
      appBar: AppBar(
        title: Text('مرحبا بك'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: backgroundColor,
      body: Container(
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width * 0.4,
              imageUrl: 'https://i.ibb.co/D7HxzHk/workflow.png',
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: fillColor,
                  size: 100,
                ),
              ),
              errorWidget: (context, url, error) => Icon(
                Icons.error,
                color: Colors.white,
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
