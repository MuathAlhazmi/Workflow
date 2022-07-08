import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:workflow/theme/colors.dart';

import '../widgets/other/snackbar.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('Notifications')
                .where('targetUsers',
                    arrayContains: FirebaseAuth.instance.currentUser!.uid)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                return Container(
                  child: ListView(
                    children: getExpenseItems(snapshot, context),
                  ),
                );
              }
              return Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: fillColor,
                  size: 100,
                ),
              );
            },
          ))
        ],
      ),
    );
  }
}

Future<types.User> targetUser(doc, e) async {
  final fetching = await fetchUser(FirebaseFirestore.instance, e, 'users');
  final user = types.User.fromJson(fetching);
  return user;
}

getExpenseItems(
  AsyncSnapshot<QuerySnapshot> snapshot,
  context,
) {
  return snapshot.data!.docs.map((doc) {
    Iterable<Future<types.User>> targetUsers =
        (doc['targetUsers'] as List).map((e) {
      return targetUser(doc, e);
    });
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10),
      child: Center(
        child: GestureDetector(
          onTap: () {},
          child: Dismissible(
            background: Container(
              decoration: BoxDecoration(
                color: Colors.redAccent,
              ),
              child: Icon(
                CupertinoIcons.trash_circle,
              ),
            ),
            movementDuration: Duration(milliseconds: 500),
            key: UniqueKey(),
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (context) => Dialog(
                  insetPadding: EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: mainColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  child: Container(
                    height: 300,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    decoration: BoxDecoration(
                        color: fillColor,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              'هل انت متأكد؟',
                              style: TextStyle(
                                  color: mainColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            Divider(
                              color: Colors.transparent,
                            ),
                            Text(
                              'هل تريد حذف هذا الإشعار  ',
                              style: TextStyle(
                                color: mainColor,
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          color: Colors.transparent,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: fillColor,
                                onPrimary: Colors.black12,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Center(
                                child: Text(
                                  'ألغاء',
                                  style: TextStyle(
                                    color: mainColor,
                                  ),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('Notifications')
                                    .doc(doc.id)
                                    .delete();
                                Navigator.pop(context);
                                snackBarWidget(context, 'تم حذف المهمة بنجاح',
                                    CupertinoIcons.check_mark, mainColor);
                              },
                              child: Center(
                                child: Text(
                                  'تأكيد',
                                  style: TextStyle(color: fillColor),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: CupertinoColors.tertiarySystemFill,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Badge(
                        position: BadgePosition.topStart(),
                        badgeColor: fillColor,
                        showBadge: !doc['read'],
                        child: Container(
                          child: CircleAvatar(
                            backgroundColor: doc['imageURL'] == null
                                ? CupertinoColors.tertiarySystemFill
                                : CupertinoColors.tertiarySystemFill,
                            backgroundImage: doc['imageURL'] == null
                                ? null
                                : NetworkImage(doc['imageURL']),
                            radius: 20,
                            child: doc['imageURL'] == null
                                ? Icon(CupertinoIcons.bell, color: fillColor)
                                : null,
                          ),
                        ),
                      ),
                      VerticalDivider(),
                      Flexible(
                        child: Text(
                          doc['userId'] ==
                                  FirebaseAuth.instance.currentUser!.uid
                              ? 'تم انشاء دعوة لمجموعة ${doc['name']}'
                              : doc['content'] ?? '',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      VerticalDivider(),
                      Text(
                        doc['date'] ?? '',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.transparent,
                ),
                doc['userId'] == FirebaseAuth.instance.currentUser!.uid
                    ? Container()
                    : doc['accepted']
                        ? Container()
                        : Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          primary: CupertinoColors
                                              .tertiarySystemFill,
                                          padding: EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 10,
                                          ),
                                          onPrimary: Colors.white38,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        onPressed: () async {
                                          await FirebaseChatCore.instance
                                              .createGroupRoom(
                                                  name: doc['name'],
                                                  imageUrl:
                                                      doc['imageURL'] == null
                                                          ? null
                                                          : doc['imageURL'],
                                                  users: await Future.wait(
                                                          targetUsers)
                                                      .then((value) => value
                                                          .getRange(
                                                              1, value.length)
                                                          .toList()));
                                          FirebaseFirestore.instance
                                              .collection('Notifications')
                                              .doc(doc.id)
                                              .update({'accepted': true});
                                        },
                                        child: Center(
                                          child: Text(
                                            'موافق',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: fillColor),
                                          ),
                                        )),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          primary: CupertinoColors
                                              .tertiarySystemFill,
                                          padding: EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 10,
                                          ),
                                          onPrimary: Colors.white38,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        onPressed: () async {
                                          await FirebaseFirestore.instance
                                              .collection('Notifications')
                                              .doc(doc.id)
                                              .delete();
                                          snackBarWidget(
                                              context,
                                              'تم الحذف بنجاح',
                                              Icons.check,
                                              mainColor);
                                        },
                                        child: Center(
                                          child: Text('غير موافق'),
                                        )),
                                  ),
                                ),
                              ),
                            ],
                          )
              ],
            ),
          ),
        ),
      ),
    );
  }).toList();
}
