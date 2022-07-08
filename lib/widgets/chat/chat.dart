import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workflow/helpers/responsive.dart';
import 'package:workflow/theme/colors.dart';
import 'package:workflow/widgets/chat/audioMessage.dart';
import 'package:workflow/widgets/chat/fullscreen.dart';
import 'package:workflow/widgets/chat/groupDetail.dart';
import 'package:workflow/widgets/chat/input.dart' as input;
import 'package:workflow/widgets/other/snackbar.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    Key? key,
    required this.room,
  }) : super(key: key);

  final types.Room room;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  void fcmSubscribe() {
    FirebaseMessaging.instance.subscribeToTopic(widget.room.id);
  }

  bool _isAttachmentUploading = false;

  Future<bool> _handleAudioRecorded({
    required Duration length,
    required String filePath,
    required List<double> waveForm,
    required String mimeType,
  }) async {
    final message = types.PartialCustom(metadata: {
      'length': length.toString(),
      'mimeType': mimeType,
      'waveForm': waveForm,
      'uri': filePath,
    });

    FirebaseChatCore.instance.sendMessage(message, widget.room.id);

    return true;
  }

  void _handleAtachmentPressed() {
    showModalBottomSheet<void>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10),
        ),
      ),
      backgroundColor: backgroundColor,
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            height: 144,
            color: backgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // TextButton(
                //   onPressed: () {
                //     Navigator.pop(context);
                //     Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //             builder: (context) => PollForm(
                //                   roomId: widget.room.id,
                //                 )));
                //   },
                //   child: Text(
                //     'تصويت',
                //     style: TextStyle(color: mainColor),
                //   ),
                // ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleImageSelection();
                  },
                  child: Text(
                    'صورة',
                    style: TextStyle(color: fillColor),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleFileSelection();
                  },
                  child: Text(
                    'ملف',
                    style: TextStyle(color: fillColor),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'إلغاء',
                    style: TextStyle(
                      color: Colors.red.withOpacity(.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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

      try {
        final reference = FirebaseStorage.instance.ref(name);
        await reference.putFile(file);
        final uri = await reference.getDownloadURL();

        final message = types.PartialFile(
          mimeType: lookupMimeType(filePath),
          name: name,
          size: result.files.single.size,
          uri: uri,
        );

        FirebaseChatCore.instance.sendMessage(message, widget.room.id);
        _setAttachmentUploading(false);
      } finally {
        _setAttachmentUploading(false);
      }
    }
  }

  String recordFilePath = '';

  void _handleImageSelection() async {
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

        final message = types.PartialImage(
          height: image.height.toDouble(),
          name: name,
          size: size,
          uri: uri,
          width: image.width.toDouble(),
        );

        FirebaseChatCore.instance.sendMessage(
          message,
          widget.room.id,
        );
        _setAttachmentUploading(false);
      } finally {
        _setAttachmentUploading(false);
      }
    }
  }

  void _handleMessageTap(BuildContext context, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        final client = http.Client();
        final request = await client.get(Uri.parse(message.uri));
        final bytes = request.bodyBytes;
        final documentsDir = (await getApplicationDocumentsDirectory()).path;
        localPath = '$documentsDir/${message.name}';

        if (!File(localPath).existsSync()) {
          final file = File(localPath);
          await file.writeAsBytes(bytes);
        }
      }

      await OpenFile.open(localPath);
    }
    if (message is types.ImageMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        final client = http.Client();
        final request = await client.get(Uri.parse(message.uri));
        final bytes = request.bodyBytes;
        final documentsDir = (await getApplicationDocumentsDirectory()).path;
        localPath = '$documentsDir/${message.name}';

        if (!File(localPath).existsSync()) {
          final file = File(localPath);
          await file.writeAsBytes(bytes);
        }
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreen(
            url: localPath,
          ),
        ),
      );
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final updatedMessage = message.copyWith(previewData: previewData);

    FirebaseChatCore.instance.updateMessage(updatedMessage, widget.room.id);
  }

  void _handleSendPressed(types.PartialText message) {
    FirebaseChatCore.instance.sendMessage(
      message,
      widget.room.id,
    );
  }

  void _setAttachmentUploading(bool uploading) {
    setState(() {
      _isAttachmentUploading = uploading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 120,
            title: MaterialButton(
              padding: EdgeInsets.all(5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GroupDetail(room: widget.room)));
              },
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back_ios),
                      ),
                      CircleAvatar(
                        backgroundColor: fillColor,
                        backgroundImage: widget.room.imageUrl == null
                            ? null
                            : CachedNetworkImageProvider(widget.room.imageUrl!),
                        radius: 20,
                        child: widget.room.imageUrl == null
                            ? Icon(Icons.group, color: mainColor)
                            : null,
                      ),
                      VerticalDivider(
                        color: Colors.transparent,
                      ),
                      Text(widget.room.name ?? 'يتم التحميل'),
                    ],
                  ),
                  Divider(
                    height: 10,
                    color: Colors.transparent,
                  ),
                  Row(
                    children: [
                      VerticalDivider(
                        width: 50,
                        color: Colors.transparent,
                      ),
                      Expanded(
                        child: Container(
                          height: 20,
                          child: Row(
                            children: [
                              Text('الأعضاء: '),
                              Expanded(
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) => Text(
                                    widget.room.users[index].firstName!,
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14),
                                  ),
                                  separatorBuilder: (context, index) => Text(
                                    '، ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14),
                                  ),
                                  itemCount: widget.room.users.length,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            backgroundColor: backgroundColor,
            elevation: 0,
          ),
          backgroundColor: backgroundColor,
          body: Center(
            child: Container(
              padding: EdgeInsets.all(5),
              width: Responsive.isMobile(context)
                  ? MediaQuery.of(context).size.width
                  : MediaQuery.of(context).size.width * 0.6,
              child: StreamBuilder<types.Room>(
                  initialData: widget.room,
                  stream: FirebaseChatCore.instance.room(widget.room.id),
                  builder: (context, snapshot) {
                    return StreamBuilder<List<types.Message>>(
                        initialData: const [],
                        stream:
                            FirebaseChatCore.instance.messages(snapshot.data!),
                        builder: (context, snapshot) {
                          return Directionality(
                            textDirection: TextDirection.ltr,
                            child: Chat(
                              customMessageBuilder: (p0,
                                  {required messageWidth}) {
                                if (p0.metadata!['length'] != null) {
                                  return AudioMessage(
                                      message: p0, messageWidth: messageWidth);
                                }
                                if (p0.metadata!['options'] != null) {}
                                return Container();
                              },
                              dateLocale: 'ar',
                              showUserNames: true,
                              emptyState: Center(
                                child: Text('لا يوجد اي رسائل بعد'),
                              ),
                              l10n: ChatL10nAr(
                                attachmentButtonAccessibilityLabel:
                                    'ارسال الملفات',
                                fileButtonAccessibilityLabel: 'مبف',
                                inputPlaceholder: '  اكتب رسالتك',
                                sendButtonAccessibilityLabel: 'ارسال',
                                emptyChatPlaceholder: 'لا يوجد رسائل سابقة',
                              ),
                              theme: DefaultChatTheme(
                                userNameTextStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  height: 1.333,
                                  color: fillColor,
                                ),
                                messageInsetsHorizontal: 20,
                                messageInsetsVertical: 20,
                                attachmentButtonIcon: Icon(
                                    CupertinoIcons.arrow_down_doc,
                                    color: fillColor),
                                sendingIcon:
                                    Icon(CupertinoIcons.ellipses_bubble),
                                sentMessageDocumentIconColor: fillColor,
                                receivedMessageDocumentIconColor: fillColor,
                                messageBorderRadius: 10,
                                dateDividerTextStyle: TextStyle(
                                    color: fillColor,
                                    fontSize: 16,
                                    fontFamily: 'Vazirmatn',
                                    fontWeight: FontWeight.bold,
                                    height: 1.5),
                                receivedMessageBodyTextStyle: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Vazirmatn',
                                    fontWeight: FontWeight.w500,
                                    height: 1.5),
                                inputTextStyle: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Vazirmatn',
                                    fontWeight: FontWeight.w500,
                                    height: 1.5),
                                primaryColor: mainColor.withOpacity(.5),
                                backgroundColor: backgroundColor,
                                secondaryColor:
                                    CupertinoColors.tertiarySystemFill,
                                inputTextColor: fillColor,
                                inputTextCursorColor: fillColor,
                                inputBackgroundColor:
                                    CupertinoColors.tertiarySystemFill,
                                inputBorderRadius: BorderRadius.circular(10),
                              ),
                              customBottomWidget: Directionality(
                                textDirection: TextDirection.rtl,
                                child: input.Input(
                                  onAudioRecorded: _handleAudioRecorded,
                                  isAttachmentUploading: _isAttachmentUploading,
                                  onAttachmentPressed: _handleAtachmentPressed,
                                  onSendPressed: _handleSendPressed,
                                  sendButtonVisibilityMode:
                                      SendButtonVisibilityMode.editing,
                                ),
                              ),
                              onMessageLongPress: (context, message) {
                                if (message.author.id ==
                                    FirebaseChatCore
                                        .instance.firebaseUser!.uid) {
                                  showDialog(
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
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 30),
                                        decoration: BoxDecoration(
                                            color: fillColor,
                                            shape: BoxShape.rectangle,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Column(
                                              children: [
                                                Text(
                                                  'هل انت متأكد؟',
                                                  style: TextStyle(
                                                      color: mainColor,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Divider(
                                                  color: Colors.transparent,
                                                ),
                                                Text(
                                                  'هل تريد حذف رسالتك',
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
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: fillColor,
                                                    onPrimary: Colors.black12,
                                                    elevation: 0,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
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
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    await FirebaseChatCore
                                                        .instance
                                                        .deleteMessage(
                                                            widget.room.id,
                                                            message.id);
                                                    Navigator.pop(context);
                                                    snackBarWidget(
                                                        context,
                                                        'تم حذف رسالتك بنجاح',
                                                        CupertinoIcons
                                                            .check_mark,
                                                        mainColor);
                                                  },
                                                  child: Center(
                                                    child: Text(
                                                      'تأكيد',
                                                      style: TextStyle(
                                                          color: fillColor),
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
                                }
                              },
                              disableImageGallery: true,
                              isAttachmentUploading: _isAttachmentUploading,
                              messages: snapshot.data ?? [],
                              onAttachmentPressed: _handleAtachmentPressed,
                              onMessageTap: _handleMessageTap,
                              onPreviewDataFetched: _handlePreviewDataFetched,
                              onSendPressed: _handleSendPressed,
                              user: types.User(
                                id: FirebaseChatCore
                                        .instance.firebaseUser?.uid ??
                                    '',
                              ),
                            ),
                          );
                        });
                  }),
            ),
          ),
        ),
      ),
    );
  }
}
