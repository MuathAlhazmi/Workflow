import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:date_picker_timeline/extra/style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:workflow/theme/colors.dart';
import 'package:workflow/todolist/detailscreen.dart';
import 'package:workflow/widgets/homepage/currentActivity.dart';
import 'package:workflow/widgets/other/snackbar.dart';

class HomeScreenPage extends StatefulWidget {
  @override
  _HomeScreenPageState createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreenPage> {
  DateTime _selectedValue = DateTime.now();
  DateTime _selectedValue1 = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Container(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          TabBar(
            enableFeedback: true,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: CircleTabIndicator(color: fillColor, radius: 4),
            indicatorColor: fillColor,
            unselectedLabelStyle: TextStyle(
                color: fillColor.withOpacity(.5),
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold),
            labelStyle: TextStyle(
                color: fillColor,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold),
            labelColor: fillColor,
            unselectedLabelColor: fillColor.withOpacity(.4),
            tabs: [
              Tab(
                icon: Icon(
                  CupertinoIcons.app_badge,
                  color: fillColor,
                ),
              ),
              Tab(
                icon: Icon(
                  CupertinoIcons.check_mark_circled,
                  color: fillColor,
                ),
              ),
            ],
          ),
          Divider(
            color: Colors.transparent,
          ),
          Expanded(
            child: TabBarView(
              children: [
                Column(
                  children: [
                    StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('Todo')
                            .where('userIds',
                                arrayContains:
                                    FirebaseAuth.instance.currentUser!.uid)
                            .where('done', isEqualTo: false)
                            .snapshots(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasData &&
                              snapshot.data!.docs.length == 0) {
                            return Container();
                          }
                          if (snapshot.hasData &&
                              snapshot.data!.docs.length > 0) {
                            return DatePicker(
                              snapshot.data!.docs
                                  .map((doc) => (DateFormat(
                                          DateFormat.YEAR_MONTH_DAY, 'ar')
                                      .parse(doc['due'])))
                                  .toList()
                                  .first,
                              height: 100,
                              locale: 'ar',
                              activeDates: snapshot.data!.docs
                                  .map((doc) => (DateFormat(
                                          DateFormat.YEAR_MONTH_DAY, 'ar')
                                      .parse(doc['due'])))
                                  .toList(),
                              initialSelectedDate: DateTime.now(),
                              selectionColor:
                                  CupertinoColors.tertiarySystemFill,
                              selectedTextColor: fillColor,
                              deactivatedColor: fillColor.withOpacity(.3),
                              dayTextStyle: defaultDayTextStyle.copyWith(
                                  color: fillColor),
                              dateTextStyle: defaultDateTextStyle.copyWith(
                                  color: fillColor),
                              monthTextStyle: defaultMonthTextStyle.copyWith(
                                  color: fillColor),
                              onDateChange: (date) {
                                // New date selected
                                setState(() {
                                  _selectedValue = date;
                                });
                              },
                            );
                          }
                          return Center(
                            child: LoadingAnimationWidget.staggeredDotsWave(
                              color: fillColor,
                              size: 100,
                            ),
                          );
                        }),
                    Expanded(
                        child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('Todo')
                          .where('done', isEqualTo: false)
                          .where('userIds',
                              arrayContains:
                                  FirebaseAuth.instance.currentUser!.uid)
                          .where('due',
                              isEqualTo:
                                  DateFormat(DateFormat.YEAR_MONTH_DAY, 'ar')
                                      .format(_selectedValue))
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Container(
                            child: Text('لا تملك اي مهام'),
                          );
                        }

                        if (snapshot.hasData) {
                          if (snapshot.data!.docs.isEmpty) {
                            return Center(child: Text('لا يوجد اي مهام '));
                          }

                          return Container(
                            child: ListView(
                              children:
                                  getExpenseItems(snapshot, context, false),
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
                    )),
                  ],
                ),
                Column(
                  children: [
                    StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('Todo')
                            .where('userIds',
                                arrayContains:
                                    FirebaseAuth.instance.currentUser!.uid)
                            .where('done', isEqualTo: true)
                            .snapshots(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasData &&
                              snapshot.data!.docs.length == 0) {
                            return Container();
                          }
                          if (snapshot.hasData &&
                              snapshot.data!.docs.length > 0) {
                            return DatePicker(
                              snapshot.data!.docs
                                  .map((doc) => (DateFormat(
                                          DateFormat.YEAR_MONTH_DAY, 'ar')
                                      .parse(doc['due'])))
                                  .toList()
                                  .first,
                              height: 100,
                              locale: 'ar',
                              activeDates: snapshot.data!.docs
                                  .map((doc) => (DateFormat(
                                          DateFormat.YEAR_MONTH_DAY, 'ar')
                                      .parse(doc['due'])))
                                  .toList(),
                              initialSelectedDate: DateTime.now(),
                              selectionColor:
                                  CupertinoColors.tertiarySystemFill,
                              selectedTextColor: fillColor,
                              deactivatedColor: fillColor.withOpacity(.3),
                              dayTextStyle: defaultDayTextStyle.copyWith(
                                  color: fillColor),
                              dateTextStyle: defaultDateTextStyle.copyWith(
                                  color: fillColor),
                              monthTextStyle: defaultMonthTextStyle.copyWith(
                                  color: fillColor),
                              onDateChange: (date) {
                                // New date selected
                                setState(() {
                                  _selectedValue1 = date;
                                });
                              },
                            );
                          }
                          return Center(
                            child: LoadingAnimationWidget.staggeredDotsWave(
                              color: fillColor,
                              size: 100,
                            ),
                          );
                        }),
                    Expanded(
                        child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('Todo')
                          .where('done', isEqualTo: true)
                          .where('userIds',
                              arrayContains:
                                  FirebaseAuth.instance.currentUser!.uid)
                          .where('due',
                              isEqualTo:
                                  DateFormat(DateFormat.YEAR_MONTH_DAY, 'ar')
                                      .format(_selectedValue1))
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Container(
                            child: Text('لا تملك اي مهلم منتهية'),
                          );
                        }

                        if (snapshot.hasData) {
                          if (snapshot.data!.docs.isEmpty) {
                            return Center(child: Text('لا يوجد اي مهام '));
                          }

                          return Container(
                            child: ListView(
                              children:
                                  getExpenseItems(snapshot, context, true),
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
                    )),
                  ],
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

getExpenseItems(AsyncSnapshot<QuerySnapshot> snapshot, context, done) {
  return snapshot.data!.docs.map((doc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10),
      child: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TodoDetail(
                          id: doc.id,
                          done: done,
                        )));
          },
          child: Dismissible(
              background: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 30),
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
              child: CurrentActivity(
                  isCompleted: doc['isCompleted'],
                  priorty: doc['priority'],
                  desc: doc['desc'],
                  title: doc['title'],
                  room: doc['room'],
                  due: doc['due'])),
        ),
      ),
    );
  }).toList();
}

class CircleTabIndicator extends Decoration {
  final BoxPainter _painter;

  CircleTabIndicator({required Color color, required double radius})
      : _painter = _CirclePainter(color, radius);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _painter;
}

class _CirclePainter extends BoxPainter {
  final Paint _paint;
  final double radius;

  _CirclePainter(Color color, this.radius)
      : _paint = Paint()
          ..color = color
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final Offset circleOffset =
        offset + Offset(cfg.size!.width / 2, cfg.size!.height - radius);
    canvas.drawCircle(circleOffset, radius, _paint);
  }
}
