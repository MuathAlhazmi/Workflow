import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:workflow/class/todoList.dart';
import 'package:workflow/helpers/responsive.dart';
import 'package:workflow/theme/colors.dart';
import 'package:workflow/utils/notfication.dart';
import 'package:workflow/widgets/other/snackbar.dart';
import 'package:workflow/widgets/other/textfields.dart';

class TodoList extends StatefulWidget {
  const TodoList({Key? key}) : super(key: key);

  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final date = TextEditingController();
  final title = TextEditingController();
  final group = TextEditingController();

  final desc = TextEditingController();
  late types.Room room;
  Widget _buildAvatar(types.Room room, bool isSelected) {
    final hasImage = room.imageUrl != null;

    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: isSelected
          ? CircleAvatar(
              backgroundColor: CupertinoColors.tertiarySystemFill,
              radius: 20,
              child: Icon(CupertinoIcons.check_mark, color: fillColor),
            )
          : CircleAvatar(
              backgroundColor: fillColor,
              backgroundImage: hasImage ? NetworkImage(room.imageUrl!) : null,
              radius: 20,
              child: !hasImage ? Icon(Icons.group, color: mainColor) : null,
            ),
    );
  }

  int value = 0;
  @override
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
                var todol = await TodoClass(
                        room: room,
                        title: title.text,
                        desc: desc.text,
                        dateTime: date.text,
                        priority: 'Low')
                    .addTodo();
                await TodoClass(
                        room: room,
                        title: title.text,
                        desc: desc.text,
                        dateTime: date.text,
                        priority: 'Low')
                    .notifyTodo();

                await addNotificationToDo(
                    '', 'Todo', 'تم إضافة مهمة لك', todol);

                snackBarWidget(context, 'تم إضافة المهمة بنجاح',
                    CupertinoIcons.check_mark, mainColor);

                Navigator.pop(context);
              },
              child: Icon(Icons.task_alt, color: mainColor),
            ),
            appBar: AppBar(
              title: Text('إضافة مهمة'),
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
                    child: Column(
                      children: [
                        Divider(
                          color: Colors.transparent,
                        ),
                        TextFieldWidget(
                          labeltext: 'عنوان المهمة',
                          textController: title,
                          hinttext: 'عنوان المهمة',
                        ),
                        Divider(
                          color: Colors.transparent,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: CupertinoColors.tertiarySystemFill,
                          ),
                          height: 80,
                          child: TextField(
                            minLines: 4,
                            maxLines: 4,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Vazirmatn',
                              color: fillColor,
                            ),
                            controller: desc,
                            cursorColor: fillColor,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
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
                                labelText: 'نبذة عن المهمة',
                                hintText: 'نبذة عن المهمة',
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
                        Divider(
                          color: Colors.transparent,
                        ),
                        GestureDetector(
                          onTap: () {
                            DatePicker.showDatePicker(context,
                                theme: DatePickerTheme(
                                  backgroundColor: backgroundColor,
                                  itemStyle: TextStyle(
                                      fontFamily: 'Vazirmatn',
                                      color: fillColor),
                                ),
                                showTitleActions: false,
                                minTime: DateTime.now(),
                                maxTime: DateTime.now().add(
                                  Duration(days: 60),
                                ), onChanged: (datevalue) {
                              setState(() {
                                print(datevalue);

                                date.text =
                                    DateFormat(DateFormat.YEAR_MONTH_DAY, 'ar')
                                        .format(datevalue);
                              });
                            },
                                onConfirm: (date) {},
                                currentTime: DateTime.now(),
                                locale: LocaleType.ar);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: CupertinoColors.tertiarySystemFill,
                            ),
                            height: 40,
                            child: TextField(
                              enabled: false,
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Vazirmatn',
                                color: fillColor,
                              ),
                              controller: date,
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
                                      borderSide: BorderSide(
                                          color: fillColor, width: 2)),
                                  focusColor: fillColor,
                                  hoverColor: fillColor,
                                  border: InputBorder.none,
                                  labelText: 'اضغط هنا لتحديد يوم التسليم',
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
                        Divider(
                          color: Colors.transparent,
                        ),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                                backgroundColor: backgroundColor,
                                context: context,
                                builder: (context) {
                                  return StatefulBuilder(builder:
                                      (BuildContext context,
                                          StateSetter setState) {
                                    return SafeArea(
                                      child: Container(
                                          child: StreamBuilder<
                                                  List<types.Room>>(
                                              stream: FirebaseChatCore.instance
                                                  .rooms(
                                                      orderByUpdatedAt: false),
                                              initialData: const [],
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  if (snapshot.data!.isEmpty) {
                                                    return Center(
                                                      child: Text(
                                                          'ليس لديك اي مجموعة'),
                                                    );
                                                  }
                                                  if (snapshot
                                                      .data!.isNotEmpty) {
                                                    return Column(
                                                      children: [
                                                        Expanded(
                                                          child:
                                                              ListView.builder(
                                                            itemCount: snapshot
                                                                .data!.length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              final room =
                                                                  snapshot.data![
                                                                      index];

                                                              return GestureDetector(
                                                                onTap: () {
                                                                  setState(() {
                                                                    value =
                                                                        index;
                                                                  });
                                                                },
                                                                child:
                                                                    Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical: 8,
                                                                  ),
                                                                  child: Row(
                                                                    children: [
                                                                      _buildAvatar(
                                                                          room,
                                                                          value ==
                                                                              index),
                                                                      VerticalDivider(
                                                                        color: Colors
                                                                            .transparent,
                                                                      ),
                                                                      Text(room
                                                                          .name!),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                        FloatingActionButton(
                                                          heroTag: 'todotag',
                                                          backgroundColor:
                                                              fillColor,
                                                          onPressed: () {
                                                            setState(() {
                                                              room = snapshot
                                                                  .data![value];
                                                              group.text =
                                                                  room.name!;
                                                            });
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Icon(
                                                            Icons
                                                                .task_alt_outlined,
                                                            color: mainColor,
                                                          ),
                                                        )
                                                      ],
                                                    );
                                                  }
                                                }
                                                return Center(
                                                  child: LoadingAnimationWidget
                                                      .staggeredDotsWave(
                                                    color: fillColor,
                                                    size: 100,
                                                  ),
                                                );
                                              })),
                                    );
                                  });
                                });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: CupertinoColors.tertiarySystemFill,
                            ),
                            height: 40,
                            child: TextField(
                              controller: group,
                              enabled: false,
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Vazirmatn',
                                color: fillColor,
                              ),
                              cursorColor: fillColor,
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
                                      borderSide: BorderSide(
                                          color: fillColor, width: 2)),
                                  focusColor: fillColor,
                                  hoverColor: fillColor,
                                  border: InputBorder.none,
                                  labelText: 'اضغط هنا لتحديد المجموعة',
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
                  )),
            ),
          ),
        ));
  }
}
