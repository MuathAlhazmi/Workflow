import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:workflow/main.dart';
import 'package:workflow/theme/colors.dart';
import 'package:workflow/widgets/chat/util.dart';

class GroupDetail extends StatefulWidget {
  const GroupDetail({Key? key, required this.room}) : super(key: key);
  final types.Room room;

  @override
  State<GroupDetail> createState() => _GroupDetailState();
}

class _GroupDetailState extends State<GroupDetail> {
  Widget _buildAvatar(types.User user) {
    final color = getUserAvatarNameColor(user);
    final hasImage = user.imageUrl != null;
    final name = getUserName(user);

    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: CircleAvatar(
        backgroundColor: hasImage ? Colors.transparent : color,
        backgroundImage: hasImage ? NetworkImage(user.imageUrl ?? '') : null,
        radius: 20,
        child: !hasImage ? Icon(CupertinoIcons.person) : null,
      ),
    );
  }

  bool _isAttachmentUploading = false;
  void _setAttachmentUploading(bool uploading) {
    setState(() {
      _isAttachmentUploading = uploading;
    });
  }

  _handleImageSelection() async {
    context.loaderOverlay.show();

    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      _setAttachmentUploading(true);
      final file = File(result.path);
      final size = file.lengthSync();
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);
      final name = result.name;

      try {
        final reference = FirebaseStorage.instance.ref(name);
        await reference.putFile(file);
        final uri = await reference.getDownloadURL();
        FirebaseFirestore.instance
            .collection('rooms')
            .doc(widget.room.id)
            .update({'imageUrl': uri});
        return uri;
      } finally {
        _setAttachmentUploading(false);
      }
    }
    context.loaderOverlay.hide();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: SafeArea(
        child: Scaffold(
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            heroTag: 'todotag',
            backgroundColor: fillColor,
            onPressed: () async {
              context.loaderOverlay.show();
              var users = widget.room.users
                  .where((element) =>
                      element.id != FirebaseAuth.instance.currentUser!.uid)
                  .toList();
              await FirebaseChatCore.instance.createGroupRoom(
                name: widget.room.name ?? '',
                users: users,
                imageUrl: widget.room.imageUrl,
              );
              await FirebaseChatCore.instance.deleteRoom(widget.room.id);
              Navigator.pop(context);
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => HomePage()));
            },
            child: Icon(
              Icons.logout,
              color: mainColor,
            ),
          ),
          appBar: AppBar(
            title: Text('تعديل المجموعة'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          backgroundColor: backgroundColor,
          body: Center(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(children: [
                  Divider(
                    color: Colors.transparent,
                  ),
                  GestureDetector(
                    onTap: () {
                      _handleImageSelection();
                    },
                    child: Container(
                        child: _isAttachmentUploading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: mainColor,
                                ),
                              )
                            : widget.room.imageUrl == null
                                ? Icon(
                                    CupertinoIcons.camera,
                                    color: mainColor,
                                  )
                                : null,
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                            color: fillColor,
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(widget.room.imageUrl ?? ''),
                            ))),
                  ),
                  Divider(
                    color: Colors.transparent,
                  ),
                  Text(
                    widget.room.name ?? '',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
                  ),
                  Divider(
                    color: Colors.transparent,
                  ),
                  Divider(
                    color: fillColor,
                  ),
                  Divider(
                    color: Colors.transparent,
                  ),
                  Text(
                    'الأعضاء',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Divider(
                    color: Colors.transparent,
                  ),
                  Expanded(
                    child: Container(
                      child: ListView.builder(
                          itemCount: widget.room.users.length,
                          itemBuilder: (context, index) => Container(
                                padding: EdgeInsets.all(8),
                                child: Row(
                                  children: [
                                    _buildAvatar(widget.room.users[index]),
                                    VerticalDivider(
                                      color: Colors.transparent,
                                    ),
                                    Text(widget.room.users[index].firstName ??
                                        ''),
                                    VerticalDivider(
                                      color: Colors.transparent,
                                      width: 3,
                                    ),
                                    Text(widget.room.users[index].lastName ??
                                        ''),
                                  ],
                                ),
                              )),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
