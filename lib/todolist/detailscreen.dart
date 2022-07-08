import 'dart:io';

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:hawk_fab_menu/hawk_fab_menu.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mime/mime.dart';
import 'package:workflow/theme/colors.dart';
import 'package:workflow/todolist/task.dart';
import 'package:workflow/widgets/chat/chat.dart';
import 'package:workflow/widgets/other/snackbar.dart';
import 'package:workflow/widgets/todo/todoFile.dart';

class TodoDetail extends StatefulWidget {
  final String id;
  final bool done;
  const TodoDetail({Key? key, required this.id, required this.done})
      : super(key: key);

  @override
  _TodoDetailState createState() => _TodoDetailState();
}

class _TodoDetailState extends State<TodoDetail> {
  double option1 = 1.0;
  double option2 = 0.0;
  double option3 = 0.0;
  double option4 = 0.0;

  List<int> options = [0, 1, 2, 3];
  bool _isAttachmentUploading = false;

  Map usersWhoVoted = {
    'kILCJQ7kqaaDm2rttu9SC3s4PAf1': 1,
    'eC1PCnnvqTbhDzCp24c99um2DRA3': 1,
  };
  void _handlePressed(types.User otherUser, BuildContext context) async {
    final room = await FirebaseChatCore.instance.createRoom(otherUser);

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatPage(
          room: room,
        ),
      ),
    );
  }

  void _handlePressedRoom(types.Room room, BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatPage(
          room: room,
        ),
      ),
    );
  }

  void _setAttachmentUploading(bool uploading) {
    setState(() {
      _isAttachmentUploading = uploading;
    });
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      _setAttachmentUploading(true);
      final name = result.files.single.name;
      final filePath = result.files.single.path!;
      final file = File(filePath);
      context.loaderOverlay.show();

      try {
        final reference = storage.FirebaseStorage.instance.ref(name);
        await reference.putFile(file);
        final uri = await reference.getDownloadURL();
        var docSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();
        var docSnapData = docSnap.data();
        var fullName =
            '${docSnapData!['firstName']}' + ' ' + '${docSnapData['lastName']}';
        await FirebaseFirestore.instance
            .collection('Todo')
            .doc(widget.id)
            .collection('files')
            .doc()
            .set({
          'file': uri,
          'mimeType': lookupMimeType(filePath),
          'name': name,
          'author': fullName,
          'size': result.files.single.size,
          'uri': uri,
        });
        _setAttachmentUploading(false);
        context.loaderOverlay.hide();
      } finally {
        _setAttachmentUploading(false);
        context.loaderOverlay.hide();
      }
    }
  }

  Widget _buildAvatar(types.Room room) {
    final hasImage = room.imageUrl != null;

    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: CircleAvatar(
        backgroundColor: fillColor,
        backgroundImage: hasImage ? NetworkImage(room.imageUrl!) : null,
        radius: 20,
        child: !hasImage ? Icon(Icons.group, color: mainColor) : null,
      ),
    );
  }

  getExpenseItems(
    AsyncSnapshot<QuerySnapshot> snapshot,
    context,
  ) {
    return snapshot.data!.docs.map((doc) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10),
        child: Center(
          child: GestureDetector(
              onTap: () {},
              child: TodoFile(
                  name: doc['name'],
                  uri: doc['uri'].toString(),
                  size: doc['size'],
                  author: doc['author'])),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            actions: [
              widget.done
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              primary: CupertinoColors.tertiarySystemFill,
                              padding: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 10,
                              ),
                              onPrimary: Colors.white38,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () async {
                              final priority = await FirebaseFirestore.instance
                                  .collection('Todo')
                                  .doc(widget.id)
                                  .get()
                                  .then(
                                (value) {
                                  var data = value.data();
                                  return data!['priority'];
                                },
                              );
                              showModalBottomSheet(
                                  backgroundColor: backgroundColor,
                                  context: context,
                                  builder: (context) {
                                    return StatefulBuilder(builder:
                                        (BuildContext context,
                                            StateSetter setState) {
                                      return SafeArea(
                                        child: Container(
                                          height: 70,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 8.0),
                                                  child: FittedBox(
                                                    child: Badge(
                                                      badgeColor: fillColor,
                                                      position: BadgePosition
                                                          .topStart(),
                                                      showBadge:
                                                          priority == 'Low',
                                                      child: ElevatedButton(
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            elevation: 0,
                                                            primary: CupertinoColors
                                                                .tertiarySystemFill,
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                              vertical: 10,
                                                              horizontal: 10,
                                                            ),
                                                            onPrimary:
                                                                Colors.white38,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                          ),
                                                          onPressed: () async {
                                                            if (priority !=
                                                                'Low') {
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'Todo')
                                                                  .doc(
                                                                      widget.id)
                                                                  .update({
                                                                'priority':
                                                                    'Low'
                                                              });
                                                            }
                                                            snackBarWidget(
                                                                context,
                                                                'تم تغيير الأولوية',
                                                                Icons.check,
                                                                fillColor);
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Center(
                                                            child: Text(
                                                              'ليست مهمة',
                                                              style: TextStyle(
                                                                  color:
                                                                      fillColor),
                                                            ),
                                                          )),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 8.0),
                                                  child: FittedBox(
                                                    child: Badge(
                                                      badgeColor: fillColor,
                                                      position: BadgePosition
                                                          .topStart(),
                                                      showBadge:
                                                          priority == 'Medium',
                                                      child: ElevatedButton(
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            elevation: 0,
                                                            primary: CupertinoColors
                                                                .tertiarySystemFill,
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                              vertical: 10,
                                                              horizontal: 10,
                                                            ),
                                                            onPrimary:
                                                                Colors.white38,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                          ),
                                                          onPressed: () async {
                                                            if (priority !=
                                                                'Medium') {
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'Todo')
                                                                  .doc(
                                                                      widget.id)
                                                                  .update({
                                                                'priority':
                                                                    'Medium'
                                                              });
                                                            }
                                                            snackBarWidget(
                                                                context,
                                                                'تم تغيير الأولوية',
                                                                Icons.check,
                                                                fillColor);
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Center(
                                                            child: Text(
                                                              'متوسطة الأهمية',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .amberAccent),
                                                            ),
                                                          )),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 8.0),
                                                  child: FittedBox(
                                                    child: Badge(
                                                      badgeColor: fillColor,
                                                      position: BadgePosition
                                                          .topStart(),
                                                      showBadge:
                                                          priority == 'High',
                                                      child: ElevatedButton(
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            elevation: 0,
                                                            primary: CupertinoColors
                                                                .tertiarySystemFill,
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                              vertical: 10,
                                                              horizontal: 10,
                                                            ),
                                                            onPrimary:
                                                                Colors.white38,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                          ),
                                                          onPressed: () async {
                                                            if (priority !=
                                                                'High') {
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'Todo')
                                                                  .doc(
                                                                      widget.id)
                                                                  .update({
                                                                'priority':
                                                                    'High'
                                                              });
                                                              snackBarWidget(
                                                                  context,
                                                                  'تم تغيير الأولوية',
                                                                  Icons.check,
                                                                  fillColor);
                                                              Navigator.pop(
                                                                  context);
                                                            }
                                                          },
                                                          child: Center(
                                                            child: Text(
                                                              'في غاية الأهمية',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .redAccent),
                                                            ),
                                                          )),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                                  });
                            },
                            child: Center(
                              child: Text(
                                'أولوية',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: fillColor),
                              ),
                            )),
                      ),
                    )
                  : Container()
            ],
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text('مهمة'),
          ),
          backgroundColor: backgroundColor,
          body: Directionality(
            textDirection: TextDirection.ltr,
            child: HawkFabMenu(
              heroTag: 'todotag',
              icon: AnimatedIcons.menu_close,
              fabColor: fillColor,
              iconColor: mainColor,
              items: [
                HawkFabMenuItem(
                  labelBackgroundColor: Colors.transparent,
                  label: 'مهمة',
                  ontap: () async {
                    await FirebaseFirestore.instance
                        .collection('Todo')
                        .doc(widget.id)
                        .collection('SubTask')
                        .add({'isCompleted': false, 'title': 'مهمة جديدة'});

                    snackBarWidget(
                        context, 'تم إضافة مهمة جديدة', Icons.check, fillColor);
                  },
                  icon: const Icon(
                    CupertinoIcons.check_mark_circled,
                    color: mainColor,
                  ),
                  color: fillColor,
                  labelColor: fillColor,
                ),
                HawkFabMenuItem(
                  labelBackgroundColor: Colors.transparent,
                  label: 'ملف',
                  ontap: _handleFileSelection,
                  icon: const Icon(
                    CupertinoIcons.arrow_up_doc,
                    color: mainColor,
                  ),
                  color: fillColor,
                  labelColor: fillColor,
                ),
                HawkFabMenuItem(
                  labelBackgroundColor: Colors.transparent,
                  label: widget.done ? 'استرجاع المهمة' : 'إنتهاء من المهمة',
                  ontap: () async {
                    if (widget.done) {
                      FirebaseFirestore.instance
                          .collection('Todo')
                          .doc(widget.id)
                          .update({'done': false});
                      snackBarWidget(
                          context, 'تم استرجاع المهمة', Icons.check, fillColor);
                    }
                    FirebaseFirestore.instance
                        .collection('Todo')
                        .doc(widget.id)
                        .update({'done': true});
                    snackBarWidget(
                        context, 'تم إنهاء المهمة', Icons.check, fillColor);
                  },
                  icon: Icon(
                    widget.done
                        ? CupertinoIcons.rectangle_badge_checkmark
                        : CupertinoIcons.arrow_clockwise_circle,
                    color: mainColor,
                  ),
                  color: fillColor,
                  labelColor: fillColor,
                ),
              ],
              body: Column(children: [
                Divider(),
                StreamBuilder<Object>(
                    stream: FirebaseFirestore.instance
                        .collection('Todo')
                        .doc(widget.id)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                            child: Text('لا يمكنك عرض هذه المهمة'));
                      } else {
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.done
                                      ? 'منتهية'
                                      : (snapshot.data
                                                  as dynamic)!['priority'] ==
                                              'Low'
                                          ? 'ليست مهمة'
                                          : (snapshot.data as dynamic)![
                                                      'priority'] ==
                                                  'Medium'
                                              ? 'متوسطة الاهمية'
                                              : (snapshot.data as dynamic)![
                                                          'priority'] ==
                                                      'High'
                                                  ? 'غاية الاهمية'
                                                  : 'تمت المهمة',
                                  style: TextStyle(
                                    color: (snapshot.data
                                                as dynamic)!['priority'] ==
                                            'Low'
                                        ? fillColor
                                        : (snapshot.data
                                                    as dynamic)!['priority'] ==
                                                'Medium'
                                            ? Colors.amberAccent
                                            : (snapshot.data as dynamic)![
                                                        'priority'] ==
                                                    'High'
                                                ? Colors.red
                                                : Colors.greenAccent,
                                  ),
                                ),
                                VerticalDivider(color: Colors.transparent),
                                Text(
                                  (snapshot.data as dynamic)!['title'],
                                  style: TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Divider(
                              color: Colors.transparent,
                            ),
                            Text(
                              (snapshot.data as dynamic)!['desc'],
                            ),
                          ],
                        );
                      }
                    }),
                Divider(
                  height: 50,
                  color: Colors.transparent,
                ),
                Text(
                  'الملفات',
                  style: TextStyle(fontSize: 20),
                ),
                Expanded(
                  child: Center(
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(),
                              child: StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('Todo')
                                      .doc(widget.id)
                                      .collection('files')
                                      .snapshots(),
                                  builder: ((context,
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.hasData) {
                                      return ListView(
                                          children: getExpenseItems(
                                              snapshot, context));
                                    }
                                    return Center(
                                        child: Text('لا توجد اي ملفات'));
                                  })),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ),
                Divider(color: Colors.transparent),
                Expanded(
                    child: Task(
                  id: widget.id,
                )),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
