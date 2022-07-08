import 'dart:io';

import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:multi_select_item/multi_select_item.dart';
import 'package:workflow/helpers/responsive.dart';
import 'package:workflow/main.dart';
import 'package:workflow/theme/colors.dart';
import 'package:workflow/utils/notfication.dart';
import 'package:workflow/widgets/chat/util.dart';
import 'package:workflow/widgets/other/snackbar.dart';
import 'package:workflow/widgets/other/textfields.dart';

Widget _buildAvatar(types.User user, bool isSelected) {
  final color = getUserAvatarNameColor(user);
  final hasImage = user.imageUrl != null;
  final name = getUserName(user);

  return Container(
    margin: const EdgeInsets.only(right: 16),
    child: isSelected
        ? CircleAvatar(
            backgroundColor: fillColor,
            radius: 20,
            child: Icon(CupertinoIcons.check_mark, color: mainColor),
          )
        : CircleAvatar(
            backgroundColor: hasImage ? Colors.transparent : color,
            backgroundImage: hasImage ? NetworkImage(user.imageUrl!) : null,
            radius: 20,
            child: !hasImage
                ? Text(
                    name.isEmpty ? '' : name[0].toUpperCase(),
                    style: const TextStyle(color: mainColor),
                  )
                : null,
          ),
  );
}

class UserPick extends StatefulWidget {
  const UserPick({Key? key}) : super(key: key);

  @override
  _UserPickState createState() => _UserPickState();
}

class _UserPickState extends State<UserPick> {
  List<types.User> multiSelectList = [];

  MultiSelectController controller = MultiSelectController();
  @override
  void initState() {
    controller.set(multiSelectList.length);
    super.initState();
  }

  void delete() {
    var list = controller.selectedIndexes;
    list.sort((b, a) => a.compareTo(b));
    list.forEach((element) {
      multiSelectList.removeAt(element);
    });

    setState(() {
      controller.set(multiSelectList.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var before = !controller.isSelecting;
        setState(() {
          controller.deselectAll();
        });
        return before;
      },
      child: Container(
        color: backgroundColor,
        child: SafeArea(
          child: Scaffold(
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: FloatingActionButton(
              heroTag: 'todotag',
              backgroundColor: fillColor,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            GroupForm(users: multiSelectList)));
              },
              child: Icon(Icons.group_add, color: mainColor),
            ),
            appBar: AppBar(
              title: Text('اختر أعضاء المجموعة'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            backgroundColor: backgroundColor,
            body: StreamBuilder<List<types.User>>(
              stream: FirebaseChatCore.instance.users(),
              initialData: const [],
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: fillColor,
                      size: 100,
                    ),
                  );
                }
                if (snapshot.data!.isEmpty) {
                  return Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(
                      bottom: 200,
                    ),
                    child: const Text('لا يوجد مستخدم'),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final user = snapshot.data![index];

                    return MultiSelectItem(
                      isSelecting: controller.isSelecting,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            controller.toggle(index);
                            if (controller.isSelected(index)) {
                              multiSelectList.add(user);
                            }
                            if (!controller.isSelected(index)) {
                              multiSelectList.remove(user);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              _buildAvatar(user, controller.isSelected(index)),
                              VerticalDivider(
                                color: Colors.transparent,
                              ),
                              Text(getUserName(user)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class GroupForm extends StatefulWidget {
  final List<types.User> users;
  GroupForm({required this.users});

  @override
  State<GroupForm> createState() => _GroupFormState();
}

class _GroupFormState extends State<GroupForm> {
  final TextEditingController groupName = TextEditingController();

  final TextEditingController lastname = TextEditingController();

  bool _isAttachmentUploading = false;
  String url = '';
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

        _setAttachmentUploading(false);
        setState(() {
          url = uri;
        });
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
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton(
            heroTag: 'todotag',
            backgroundColor: fillColor,
            onPressed: () async {
              List<String> users = widget.users.map((e) => e.id).toList();
              users.add(FirebaseAuth.instance.currentUser!.uid);
              if (!_isAttachmentUploading) {
                if (widget.users.isEmpty) {
                  snackBarWidget(context, 'لابد من إضافة مستخدمين', Icons.error,
                      mainColor);
                }
                if (groupName.text.isEmpty) {
                  snackBarWidget(
                      context, 'لابد من إضافة إسم', Icons.error, mainColor);
                } else {
                  // var room = await FirebaseChatCore.instance.createGroupRoom(
                  //   name: groupName.text,
                  //   imageUrl: url == '' ? null : url,
                  //   users: widget.users,
                  // );
                  await addNotificationChat(
                    url,
                    'Room',
                    'تم دعوتك في مجموعة  ${groupName.text}',
                    users,
                    groupName.text,
                  );
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HomePage()));
                }
              }
            },
            child: Icon(Icons.group_add, color: mainColor),
          ),
          appBar: AppBar(
            title: Text('معلومات المجموعة'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          backgroundColor: backgroundColor,
          body: Center(
            child: Container(
              width: Responsive.isMobile(context)
                  ? MediaQuery.of(context).size.width
                  : MediaQuery.of(context).size.width * 0.6,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(children: [
                  GestureDetector(
                    onTap: () {
                      if (url == '') {
                        _handleImageSelection();
                      }
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
                            : url == ''
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
                              image: NetworkImage(url),
                            ))),
                  ),
                  Divider(
                    color: Colors.transparent,
                  ),
                  TextFieldWidget(
                    labeltext: 'الاسم المجموعة',
                    textController: groupName,
                    hinttext: 'اسم المجموعة',
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
