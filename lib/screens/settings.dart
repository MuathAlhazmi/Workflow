import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:workflow/helpers/responsive.dart';
import 'package:workflow/screens/landingPage.dart';
import 'package:workflow/theme/colors.dart';
import 'package:workflow/widgets/chat/util.dart';
import 'package:workflow/widgets/other/settingslist.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isAttachmentUploading = false;
  String url = '';
  void _setAttachmentUploading(bool uploading) {
    setState(() {
      _isAttachmentUploading = uploading;
    });
  }

  Widget _buildAvatar(types.User user, name, image, bool isSelected) {
    final color = getUserAvatarNameColor(user);
    final hasImage = image != null;
    return Container(
      child: isSelected
          ? CircleAvatar(
              backgroundColor: fillColor,
              radius: 50,
              child: Icon(CupertinoIcons.check_mark, color: mainColor),
            )
          : CircleAvatar(
              backgroundColor: hasImage ? Colors.transparent : color,
              backgroundImage: hasImage ? NetworkImage(image!) : null,
              radius: 50,
              child: !hasImage
                  ? name == 'null null'
                      ? Icon(CupertinoIcons.profile_circled,
                          size: 30, color: mainColor)
                      : Text(
                          name.isEmpty ? '' : name[0].toUpperCase(),
                          style:
                              const TextStyle(color: mainColor, fontSize: 30),
                        )
                  : null,
            ),
    );
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
        FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({'imageUrl': url});
        context.loaderOverlay.hide();

        return uri;
      } finally {
        _setAttachmentUploading(false);
        context.loaderOverlay.hide();
      }
    }
    context.loaderOverlay.hide();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              child: Responsive.isMobile(context)
                  ? Column(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              child: _isAttachmentUploading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: mainColor,
                                      ),
                                    )
                                  : url == ''
                                      ? _buildAvatar(
                                          types.User(
                                              id: FirebaseAuth
                                                  .instance.currentUser!.uid),
                                          '${(snapshot.data as dynamic)['firstName']} ${(snapshot.data as dynamic)['lastName']}',
                                          (snapshot.data
                                              as dynamic)['imageUrl'],
                                          false)
                                      : _buildAvatar(
                                          types.User(
                                              id: FirebaseAuth
                                                  .instance.currentUser!.uid),
                                          '${(snapshot.data as dynamic)['firstName']} ${(snapshot.data as dynamic)['lastName']}',
                                          (snapshot.data
                                              as dynamic)['imageUrl'],
                                          false),
                            ),
                          ],
                        ),
                        Divider(
                          color: Colors.transparent,
                        ),
                        Row(
                          children: [
                            Expanded(child: Container()),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      primary:
                                          CupertinoColors.tertiarySystemFill,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 10,
                                      ),
                                      onPrimary: Colors.white38,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: _handleImageSelection,
                                    child: Center(
                                      child: Text(
                                        'تعديل الصورة',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: fillColor),
                                      ),
                                    )),
                              ),
                            ),
                            Expanded(child: Container()),
                          ],
                        ),
                        Divider(
                          color: Colors.transparent,
                        ),
                        SettingsList(
                          iconData: CupertinoIcons.lock,
                          title: 'الأمان',
                          onTap: () {},
                        ),
                        Divider(
                          color: Colors.transparent,
                        ),
                        SettingsList(
                          iconData: Icons.notifications_none,
                          title: 'الإشعارات',
                          onTap: () {},
                        ),
                        Divider(
                          color: Colors.transparent,
                        ),
                        SettingsList(
                          iconData: CupertinoIcons.hand_raised,
                          title: 'الخصوصية',
                          onTap: () {},
                        ),
                        Divider(
                          color: Colors.transparent,
                        ),
                        SettingsList(
                          iconData: Icons.login_outlined,
                          title: 'تسجيل الخروج',
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LandingPage(
                                          signingout: true,
                                        )),
                                (route) => false);
                          },
                        ),
                      ],
                    )
                  : Center(
                      child: Container(
                        width: 500,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SettingsList(
                                iconData: CupertinoIcons.lock,
                                title: 'الأمان',
                                onTap: () {},
                              ),
                              SettingsList(
                                iconData: Icons.notifications_none,
                                title: 'الإشعارات',
                                onTap: () {},
                              ),
                              SettingsList(
                                iconData: CupertinoIcons.hand_raised,
                                title: 'الخصوصية',
                                onTap: () {},
                              ),
                              SettingsList(
                                iconData: Icons.login_outlined,
                                title: 'تسجيل الخروج',
                                onTap: () {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LandingPage(
                                                signingout: true,
                                              )),
                                      (route) => false);
                                },
                              ),
                            ]),
                      ),
                    ),
            );
          }
          return Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: fillColor,
              size: 100,
            ),
          );
        });
  }
}
