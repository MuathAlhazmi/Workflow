import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:workflow/theme/colors.dart';
import 'package:workflow/widgets/other/snackbar.dart';

import 'chat.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({Key? key}) : super(key: key);

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
    context.loaderOverlay.show();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatPage(
          room: room,
        ),
      ),
    );
    context.loaderOverlay.hide();
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<types.Room>>(
        stream: FirebaseChatCore.instance.rooms(orderByUpdatedAt: false),
        initialData: const [],
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.length == 0) {
              return Center(
                child: Text('لا توجد اي دردشات'),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final room = snapshot.data![index];

                return Dismissible(
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 30),
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
                                    'هل تريد حذف محادثاتك مع ${room.name} ',
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
                                      await FirebaseChatCore.instance
                                          .deleteRoom(room.id);
                                      Navigator.pop(context);
                                      snackBarWidget(
                                          context,
                                          'تم حذف المحادثات بنجاح',
                                          CupertinoIcons.check_mark,
                                          mainColor);
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
                  child: GestureDetector(
                    onTap: () {
                      _handlePressedRoom(room, context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: CupertinoColors.tertiarySystemFill),
                        child: Row(
                          children: [
                            _buildAvatar(room),
                            VerticalDivider(
                              color: Colors.transparent,
                            ),
                            Text(room.name!),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
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
