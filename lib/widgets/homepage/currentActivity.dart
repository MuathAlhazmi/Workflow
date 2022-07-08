import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:workflow/helpers/responsive.dart';
import 'package:workflow/theme/colors.dart';

class CurrentActivity extends StatefulWidget {
  final String desc;
  final String title;
  final String room;
  final String priorty;
  final bool isCompleted;
  final String due;
  const CurrentActivity(
      {Key? key,
      required this.desc,
      required this.title,
      required this.room,
      required this.due,
      required this.priorty,
      required this.isCompleted})
      : super(key: key);

  @override
  _CurrentActivityState createState() => _CurrentActivityState();
}

class _CurrentActivityState extends State<CurrentActivity> {
  @override
  Widget build(BuildContext context) {
    return Badge(
      position: BadgePosition.topStart(),
      badgeColor: widget.priorty == 'Low'
          ? fillColor
          : widget.priorty == 'Medium'
              ? Colors.amberAccent
              : widget.priorty == 'High'
                  ? Colors.red
                  : Colors.greenAccent,
      child: Container(
          width: Responsive.isMobile(context)
              ? MediaQuery.of(context).size.width * 0.6
              : MediaQuery.of(context).size.width * 0.4,
          height: 100,
          decoration: BoxDecoration(
            color: CupertinoColors.tertiarySystemFill,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: fillColor,
                      ),
                    ),
                    Text(
                      'المجموعة: ${widget.room}',
                      style: TextStyle(
                        color: fillColor,
                      ),
                    ),
                    Text(
                      'يوم التسليم: ${widget.due}',
                      style: TextStyle(color: fillColor),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
