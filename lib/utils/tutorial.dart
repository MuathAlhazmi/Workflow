// import 'package:flutter/material.dart';
// import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
// import 'package:workflow/theme/colors.dart';

// void showTutorial(context, targets) {
//   TutorialCoachMark tutorial = TutorialCoachMark(context,
//       opacityShadow: 0.85,
//       pulseEnable: true,
//       textSkip: 'تخطي',
//       alignSkip: Alignment.bottomLeft,
//       targets: targets, // List<TargetFocus>
//       colorShadow: mainColor, // DEFAULT Colors.black
//       // alignSkip: Alignment.bottomRight,
//       // textSkip: "SKIP",
//       // paddingFocus: 10,
//       // focusAnimationDuration: Duration(milliseconds: 500),
//       // unFocusAnimationDuration: Duration(millisconds: 500),
//       // pulseAnimationDuration: Duration(milliseconds: 500),
//       // pulseVariation: Tween(begin: 1.0, end: 0.99),
//       onFinish: () {
//         print("finish");
//       },
//       onClickTargetWithTapPosition: (target, tapDetails) {
//         print("target: $target");
//         print(
//             "clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
//       },
//       onClickTarget: (target) {
//       },
//       onSkip: () {
//         print("skip");
//       })
//     ..show();

//   // tutorial.skip();
//   // tutorial.finish();
//   // tutorial.next(); // call next target programmatically
//   // tutorial.previous(); // call previous target programmatically
// }
