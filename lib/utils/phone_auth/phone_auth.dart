import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:workflow/theme/colors.dart';
import 'package:workflow/widgets/other/snackbar.dart';

class VerifyPhoneNumberScreen extends StatefulWidget {
  final String phoneNumber;

  VerifyPhoneNumberScreen({
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<VerifyPhoneNumberScreen> createState() =>
      _VerifyPhoneNumberScreenState();
}

class _VerifyPhoneNumberScreenState extends State<VerifyPhoneNumberScreen> {
  final textcontroller = TextEditingController();
  final focusNode = FocusNode();

  @override
  void dispose() {
    textcontroller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  String? _enteredOTP;

  void _showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: TextStyle(fontSize: 22, color: mainColor),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: mainColor.withOpacity(.5)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return FirebasePhoneAuthProvider(
      child: Container(
        color: backgroundColor,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: backgroundColor,
            body: Container(
              child: FirebasePhoneAuthHandler(
                phoneNumber: widget.phoneNumber,
                timeOutDuration: const Duration(seconds: 60),
                onLoginSuccess: (userCredential, autoVerified) async {
                  snackBarWidget(
                    context,
                    'تم التحقق بنجاح',
                    CupertinoIcons.check_mark,
                    fillColor,
                  );

                  debugPrint(
                    autoVerified
                        ? "OTP was fetched automatically"
                        : "OTP was verified manually",
                  );

                  debugPrint("Login Success UID: ${userCredential.user?.uid}");
                },
                onLoginFailed: (e) {
                  if (e.code == 'user-not-found') {
                    snackBarWidget(context, "لم يتم العثور على هذا الحساب",
                        Icons.error, Colors.white);
                  }
                  if (e.code == 'invalid-email') {
                    snackBarWidget(context, "اكتب البريد الالكتروني",
                        Icons.error, Colors.white);
                  }
                  if (e.code == 'wrong-password') {
                    snackBarWidget(context, "ان الرمز المدخل غير صحيح",
                        Icons.error, Colors.white);
                  }

                  debugPrint(e.message);
                  // handle error further if needed
                },
                builder: (context, controller) {
                  return Scaffold(
                    backgroundColor: backgroundColor,
                    appBar: AppBar(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      title: const Text("التحقق من رقم الجوال"),
                      actions: [
                        if (controller.codeSent)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: fillColor,
                                  padding: EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 10,
                                  ),
                                  onPrimary: Colors.white38,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  controller.timerIsActive
                                      ? "${controller.timerCount.inSeconds}s"
                                      : "إعادة ارسال",
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 18,
                                  ),
                                ),
                                onPressed: controller.timerIsActive
                                    ? null
                                    : () async => await controller.sendOTP(),
                              ),
                            ),
                          ),
                        const SizedBox(width: 5),
                      ],
                    ),
                    body: controller.codeSent
                        ? ListView(
                            padding: const EdgeInsets.all(20),
                            children: [
                              Text(
                                "قمنا بإرسال رمز التحقق إلى ${widget.phoneNumber}",
                                style: const TextStyle(
                                  fontSize: 25,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Divider(),
                              SizedBox(
                                height: 68,
                                child: Pinput(
                                  controller: textcontroller,
                                  focusNode: focusNode,
                                  defaultPinTheme: defaultPinTheme,
                                  showCursor: true,
                                  obscureText: true,
                                  hapticFeedbackType:
                                      HapticFeedbackType.lightImpact,
                                  onCompleted: (pin) => print(pin),
                                  cursor: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(bottom: 9),
                                        width: 22,
                                        height: 1,
                                        color: mainColor,
                                      ),
                                    ],
                                  ),
                                  focusedPinTheme: defaultPinTheme.copyWith(
                                    height: 56,
                                    width: 56,
                                    decoration:
                                        defaultPinTheme.decoration!.copyWith(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: mainColor),
                                    ),
                                  ),
                                  submittedPinTheme: defaultPinTheme.copyWith(
                                    height: 56,
                                    width: 56,
                                    decoration:
                                        defaultPinTheme.decoration!.copyWith(
                                      color: fillColor,
                                      borderRadius: BorderRadius.circular(19),
                                      border: Border.all(color: mainColor),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: const [
                              CircularProgressIndicator.adaptive(),
                              SizedBox(height: 50),
                              Center(
                                child: Text(
                                  "يتم إسال رمز التحقق",
                                  style: TextStyle(fontSize: 25),
                                ),
                              ),
                            ],
                          ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
