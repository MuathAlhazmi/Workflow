import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:workflow/theme/colors.dart';
import 'package:workflow/widgets/chat/util.dart';
import 'package:workflow/widgets/other/snackbar.dart';

class SubTaskCard extends StatefulWidget {
  SubTaskCard(
      {required Key key,
      required this.isCompleted,
      required this.title,
      required this.docId,
      required this.id})
      : super(key: key);

  final String title;
  bool isCompleted;
  final String docId;
  final String id;

  @override
  State<SubTaskCard> createState() => _SubTaskState();
}

class _SubTaskState extends State<SubTaskCard> {
  final TextEditingController subTaskController = TextEditingController();

  @override
  void initState() {
    subTaskController.text = widget.title;
    super.initState();
  }

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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dismissible(
          background: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
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
                                color: mainColor, fontWeight: FontWeight.bold),
                          ),
                          Divider(
                            color: Colors.transparent,
                          ),
                          Text(
                            'هل تريد حذف هذه المهمة  ',
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
                                  .collection('Todo')
                                  .doc(widget.docId)
                                  .collection('SubTask')
                                  .doc(widget.id)
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
                height: 50,
                decoration: BoxDecoration(
                  color: CupertinoColors.tertiarySystemFill,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Checkbox(
                          activeColor: fillColor,
                          shape:
                              CircleBorder(side: BorderSide(color: fillColor)),
                          checkColor: mainColor,
                          value: widget.isCompleted,
                          onChanged: (value) {
                            print(value);
                            widget.isCompleted = value!;
                            FirebaseFirestore.instance
                                .collection('Todo')
                                .doc(widget.docId)
                                .collection('SubTask')
                                .doc(widget.id)
                                .update({'isCompleted': value});
                          }),
                      Flexible(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: CupertinoColors.tertiarySystemFill,
                          ),
                          height: 40,
                          child: TextField(
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Vazirmatn',
                              color: fillColor,
                            ),
                            onSubmitted: (newTitle) {
                              FirebaseFirestore.instance
                                  .collection('Todo')
                                  .doc(widget.docId)
                                  .collection('SubTask')
                                  .doc(widget.id)
                                  .update({'title': newTitle});
                            },
                            controller: subTaskController,
                            cursorColor: mainColor,
                            decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 10),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: Colors.transparent, width: 2)),
                                disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: Colors.transparent, width: 2)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: fillColor, width: 2)),
                                focusColor: fillColor,
                                hoverColor: fillColor,
                                border: InputBorder.none,
                                labelText: 'ادخل عنوان',
                                hintStyle: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Vazirmatn',
                                  color: fillColor,
                                ),
                                labelStyle: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Vazirmatn',
                                  color: fillColor,
                                ),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 5,
                color: Colors.transparent,
              ),
            ],
          )),
    );
  }
}
