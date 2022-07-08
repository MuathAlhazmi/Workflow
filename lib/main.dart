import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sizer/sizer.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:workflow/firebase_options.dart';
import 'package:workflow/helpers/navbar.dart';
import 'package:workflow/helpers/responsive.dart';
import 'package:workflow/screens/homePage.dart';
import 'package:workflow/screens/login.dart';
import 'package:workflow/screens/notificationPage.dart';
import 'package:workflow/screens/settings.dart';
import 'package:workflow/theme/colors.dart';
import 'package:workflow/todolist/pick.dart';
import 'package:workflow/utils/tutorial.dart';
import 'package:workflow/widgets/chat/userPick.dart';
import 'package:workflow/widgets/chat/users.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  //firebase push notification
  AwesomeNotifications().createNotificationFromJsonData(message.data);
}

var keyButton = GlobalKey();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      'resource://drawable/res_app_icon',
      [
        NotificationChannel(
            channelGroupKey: 'basic_channel_group',
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: mainColor,
            ledColor: Colors.white)
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
            channelGroupkey: 'basic_channel_group',
            channelGroupName: 'Basic group')
      ],
      debug: true);
  AwesomeNotifications()
      .actionStream
      .listen((ReceivedNotification receivedNotification) {});
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('ar'),
        ],
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: createMaterialColor(mainColor),
          fontFamily: 'Vazirmatn',
        ),
        home: LoaderOverlay(
            child: FirebaseAuth.instance.currentUser != null
                ? HomePage()
                : SignUp()),
      );
    });
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TargetFocus> targets = [];

  int pageIndex = 0;
  @override
  void initState() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // This is just a basic example. For real apps, you must show some
        // friendly dialog box before call the request method.
        // This is very important to not harm the user experience
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    // targets
    //     .add(TargetFocus(identify: "Target 1", keyTarget: keyButton, contents: [
    //   TargetContent(
    //       align: ContentAlign.top,
    //       child: Container(
    //         child: Column(
    //           mainAxisSize: MainAxisSize.min,
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: <Widget>[
    //             Text(
    //               "لإضافة مجموعة جديدة ",
    //               style: TextStyle(
    //                   fontWeight: FontWeight.bold,
    //                   color: Colors.white,
    //                   fontSize: 20.0),
    //             ),
    //             Padding(
    //               padding: const EdgeInsets.only(top: 10.0),
    //               child: Text(
    //                 "عندما تضيف مجموعة ويوافق المدعو دعوتك بإمكانك ان تضيف مهام مشتركة",
    //                 style: TextStyle(color: Colors.white),
    //               ),
    //             )
    //           ],
    //         ),
    //       ))
    // ]));

    super.initState();
    // showTutorial(context, targets);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: SafeArea(
        child: Scaffold(
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: selectedIndex == 0
                ? FloatingActionButton(
                    key: keyButton,
                    heroTag: 'todotag',
                    backgroundColor: fillColor,
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => UserPick()));
                    },
                    child: Icon(Icons.add, color: mainColor),
                  )
                : selectedIndex == 1
                    ? FloatingActionButton(
                        heroTag: 'todotag',
                        backgroundColor: fillColor,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TodoList()));
                        },
                        child: Icon(Icons.add, color: mainColor),
                      )
                    : null,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'مهامي',
                ),
              ),
            ),
            backgroundColor: backgroundColor,
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Responsive.isDesktop(context)
                  ? null
                  : GNav(
                      onTabChange: (value) {
                        setState(() {
                          selectedIndex = value;
                        });
                      },
                      selectedIndex: selectedIndex,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      haptic: true,
                      tabBorderRadius: 15,
                      curve: Curves.easeInOut,
                      duration: Duration(milliseconds: 300),
                      gap: 5,
                      tabMargin: EdgeInsets.symmetric(horizontal: 10),
                      tabBackgroundColor: Colors.transparent,
                      color: mainColor,
                      activeColor: fillColor,
                      iconSize: 24,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      tabs: [
                          GButton(
                            icon: CupertinoIcons.chat_bubble_2,
                            text: 'الدردشات',
                          ),
                          GButton(
                            icon: CupertinoIcons.checkmark_circle,
                            text: 'المهام',
                          ),
                          GButton(
                            icon: CupertinoIcons.bell,
                            text: 'الإشعارات',
                          ),
                          GButton(
                            icon: CupertinoIcons.profile_circled,
                            text: 'الحساب',
                          )
                        ]),
            ),
            body: Responsive.isDesktop(context)
                ? Row(children: <Widget>[
                    NavigationRail(
                      selectedIconTheme: IconThemeData(color: fillColor),
                      unselectedIconTheme: IconThemeData(color: mainColor),
                      selectedLabelTextStyle:
                          TextStyle(color: fillColor, fontSize: 12),
                      unselectedLabelTextStyle:
                          TextStyle(color: mainColor, fontSize: 12),
                      backgroundColor: backgroundColor,
                      onDestinationSelected: (value) {
                        setState(() {
                          selectedIndex = value;
                        });
                      },
                      selectedIndex: selectedIndex,
                      labelType: NavigationRailLabelType.selected,
                      destinations: [
                        NavigationRailDestination(
                          icon: Icon(
                            CupertinoIcons.chat_bubble_2,
                          ),
                          label: Text(
                            'الدردشات',
                            style: TextStyle(fontFamily: 'Vazirmatn'),
                          ),
                        ),
                        NavigationRailDestination(
                          icon: Icon(
                            CupertinoIcons.check_mark_circled,
                          ),
                          label: Text(
                            'المهام',
                            style: TextStyle(fontFamily: 'Vazirmatn'),
                          ),
                        ),
                        NavigationRailDestination(
                          icon: Icon(
                            CupertinoIcons.bell,
                          ),
                          label: Text(
                            'الإشعارات',
                            style: TextStyle(fontFamily: 'Vazirmatn'),
                          ),
                        ),
                        NavigationRailDestination(
                          icon: Icon(
                            CupertinoIcons.profile_circled,
                          ),
                          label: Text(
                            'الحساب',
                            style: TextStyle(fontFamily: 'Vazirmatn'),
                          ),
                        ),
                      ],
                    ),
                    VerticalDivider(
                      thickness: 1,
                      width: 1,
                    ),
                    // This is the main content.
                    Expanded(
                        child: selectedIndex == 0
                            ? UsersPage()
                            : selectedIndex == 2
                                ? NotificationPage()
                                : selectedIndex == 3
                                    ? SettingsPage()
                                    : HomeScreenPage())
                  ])
                : selectedIndex == 0
                    ? UsersPage()
                    : selectedIndex == 2
                        ? NotificationPage()
                        : selectedIndex == 3
                            ? SettingsPage()
                            : HomeScreenPage()),
      ),
    );
  }
}
