import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:workflow/helpers/responsive.dart';
import 'package:workflow/helpers/user.dart';
import 'package:workflow/main.dart';
import 'package:workflow/theme/colors.dart';
import 'package:workflow/widgets/other/snackbar.dart';
import 'package:workflow/widgets/other/textfields.dart';

class SignUp extends StatefulWidget {
  final TextEditingController firstname = TextEditingController();

  final TextEditingController lastname = TextEditingController();

  final TextEditingController email = TextEditingController();

  final TextEditingController password = TextEditingController();

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: Responsive.isMobile(context)
                          ? MediaQuery.of(context).size.width
                          : MediaQuery.of(context).size.width * 0.6,
                      child: Column(children: [
                        TextFieldWidget(
                          labeltext: 'الاسم الاول',
                          textController: widget.firstname,
                          hinttext: 'محمد',
                        ),
                        Divider(
                          color: Colors.transparent,
                        ),
                        TextFieldWidget(
                          labeltext: 'الاسم الاخير',
                          textController: widget.lastname,
                          hinttext: 'سليمان',
                        ),
                        Divider(
                          color: Colors.transparent,
                        ),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: CupertinoColors.tertiarySystemFill,
                            ),
                            height: 40,
                            child: TextField(
                              controller: widget.email,
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Vazirmatn',
                                color: fillColor,
                              ),
                              cursorColor: fillColor,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: Colors.transparent, width: 2)),
                                  disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: Colors.transparent, width: 2)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: fillColor, width: 2)),
                                  focusColor: fillColor,
                                  hoverColor: fillColor,
                                  border: InputBorder.none,
                                  labelText: 'البريد الالكتروني',
                                  hintText: 'mohammed@gmail.com',
                                  hintStyle: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Vazirmatn',
                                    color: fillColor,
                                  ),
                                  labelStyle: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Vazirmatn',
                                    color: fillColor,
                                  ),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never),
                            ),
                          ),
                        ),
                        Divider(
                          color: Colors.transparent,
                        ),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: CupertinoColors.tertiarySystemFill,
                            ),
                            height: 40,
                            child: TextField(
                              controller: widget.password,
                              obscureText: true,
                              obscuringCharacter: '*',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Vazirmatn',
                                color: fillColor,
                              ),
                              cursorColor: mainColor,
                              decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: Colors.transparent, width: 2)),
                                  disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: Colors.transparent, width: 2)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: fillColor, width: 2)),
                                  focusColor: fillColor,
                                  hoverColor: fillColor,
                                  border: InputBorder.none,
                                  labelText: 'كلمة السر',
                                  hintText: '***********',
                                  hintStyle: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Vazirmatn',
                                    color: fillColor,
                                  ),
                                  labelStyle: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Vazirmatn',
                                    color: fillColor,
                                  ),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never),
                            ),
                          ),
                        ),
                        Divider(
                          color: Colors.transparent,
                        ),
                        Container(
                          width: Responsive.isMobile(context)
                              ? MediaQuery.of(context).size.width
                              : MediaQuery.of(context).size.width * 0.6,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              primary: fillColor,
                              onPrimary: Colors.white38,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () async {
                              try {
                                UserCredential userCredential =
                                    await FirebaseAuth.instance
                                        .createUserWithEmailAndPassword(
                                  email: widget.email.text,
                                  password: widget.password.text,
                                );

                                User? user = userCredential.user;
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user!.uid)
                                    .set({
                                  'email': widget.email.text,
                                  'firstname': widget.firstname.text,
                                  'lastname': widget.lastname.text,
                                });
                                createUser(
                                    userCredential.user!.uid,
                                    widget.firstname.text,
                                    widget.lastname.text);

                                snackBarWidget(context, "تم تسجيل الدخول بنجاح",
                                    CupertinoIcons.check_mark, Colors.white);
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomePage()));
                              } on FirebaseAuthException catch (e) {
                                print(e.message);

                                if (e.code == 'email-already-in-use') {
                                  snackBarWidget(
                                      context,
                                      "ان البريد الالكتروني مسجل من قبل",
                                      Icons.error,
                                      Colors.white);
                                }
                                if (e.code == 'weak-password') {
                                  snackBarWidget(
                                      context,
                                      "ان الرمز المدخل ضعيف",
                                      Icons.error,
                                      Colors.white);
                                }
                                if (e.code == 'invalid-email') {
                                  snackBarWidget(
                                      context,
                                      "ان البريد الالكتروني غير صحيح",
                                      Icons.error,
                                      Colors.white);
                                }
                                if (e.code == 'missing-email') {
                                  snackBarWidget(
                                      context,
                                      "ادخل البريد الالكتروني",
                                      Icons.error,
                                      Colors.white);
                                }
                              }
                            },
                            child: Center(
                              child: Text('انشاء حساب',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .copyWith(color: mainColor)),
                            ),
                          ),
                        ),
                        Divider(
                          color: Colors.transparent,
                        ),
                        Container(
                          width: Responsive.isMobile(context)
                              ? MediaQuery.of(context).size.width
                              : MediaQuery.of(context).size.width * 0.6,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              padding: EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              onPrimary: Colors.white38,
                              primary: CupertinoColors.tertiarySystemFill,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreenIOS()));
                            },
                            child: Center(
                              child: Text('تسجيل الدخول',
                                  style: Theme.of(context).textTheme.headline5),
                            ),
                          ),
                        )
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginScreenIOS extends StatefulWidget {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  @override
  _LoginScreenIOSState createState() => _LoginScreenIOSState();
}

class _LoginScreenIOSState extends State<LoginScreenIOS> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: Responsive.isMobile(context)
                          ? MediaQuery.of(context).size.width
                          : MediaQuery.of(context).size.width * 0.6,
                      child: Column(
                        children: [
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: CupertinoColors.tertiarySystemFill,
                              ),
                              height: 40,
                              child: TextField(
                                controller: widget.email,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Vazirmatn',
                                  color: fillColor,
                                ),
                                cursorColor: fillColor,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: Colors.transparent,
                                            width: 2)),
                                    disabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: Colors.transparent,
                                            width: 2)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: fillColor, width: 2)),
                                    focusColor: fillColor,
                                    hoverColor: fillColor,
                                    border: InputBorder.none,
                                    labelText: 'البريد الالكتروني',
                                    hintText: 'mohammed@gmail.com',
                                    hintStyle: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Vazirmatn',
                                      color: fillColor,
                                    ),
                                    labelStyle: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Vazirmatn',
                                      color: fillColor,
                                    ),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.never),
                              ),
                            ),
                          ),
                          Divider(
                            color: Colors.transparent,
                          ),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: CupertinoColors.tertiarySystemFill,
                              ),
                              height: 40,
                              child: TextField(
                                controller: widget.password,
                                obscureText: true,
                                obscuringCharacter: '*',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Vazirmatn',
                                  color: fillColor,
                                ),
                                cursorColor: mainColor,
                                decoration: InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: Colors.transparent,
                                            width: 2)),
                                    disabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: Colors.transparent,
                                            width: 2)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: fillColor, width: 2)),
                                    focusColor: fillColor,
                                    hoverColor: fillColor,
                                    border: InputBorder.none,
                                    labelText: 'كلمة السر',
                                    hintText: '***********',
                                    hintStyle: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Vazirmatn',
                                      color: fillColor,
                                    ),
                                    labelStyle: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Vazirmatn',
                                      color: fillColor,
                                    ),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.never),
                              ),
                            ),
                          ),
                          Divider(
                            color: Colors.transparent,
                          ),
                          Container(
                            width: Responsive.isMobile(context)
                                ? MediaQuery.of(context).size.width
                                : MediaQuery.of(context).size.width * 0.6,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                primary: fillColor,
                                onPrimary: Colors.white38,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () async {
                                try {
                                  UserCredential userCredential =
                                      await FirebaseAuth
                                          .instance
                                          .signInWithEmailAndPassword(
                                              email: widget.email.text,
                                              password: widget.password.text);
                                  snackBarWidget(
                                      context,
                                      "تم تسجيل الدخول بنجاح",
                                      CupertinoIcons.check_mark,
                                      Colors.white);
                                  Navigator.pop(context);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HomePage()));
                                } on FirebaseAuthException catch (e) {
                                  print(e);

                                  if (e.code == 'user-not-found') {
                                    snackBarWidget(
                                        context,
                                        "لم يتم العثور على هذا الحساب",
                                        Icons.error,
                                        Colors.white);
                                  }
                                  if (e.code == 'invalid-email') {
                                    snackBarWidget(
                                        context,
                                        "اكتب البريد الالكتروني",
                                        Icons.error,
                                        Colors.white);
                                  }
                                  if (e.code == 'wrong-password') {
                                    snackBarWidget(
                                        context,
                                        "ان الرمز المدخل غير صحيح",
                                        Icons.error,
                                        Colors.white);
                                  }
                                }
                              },
                              child: Center(
                                child: Text('تسجيل الدخول',
                                    style: TextStyle(color: mainColor)),
                              ),
                            ),
                          ),
                          Divider(color: Colors.transparent),
                          Container(
                            width: Responsive.isMobile(context)
                                ? MediaQuery.of(context).size.width
                                : MediaQuery.of(context).size.width * 0.6,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                padding: EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                onPrimary: Colors.white38,
                                primary: CupertinoColors.tertiarySystemFill,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SignUp()));
                              },
                              child: Center(
                                child: Text(
                                  'انشاء حساب',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
