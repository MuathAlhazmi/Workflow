import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workflow/theme/colors.dart';

class CurrentDate extends StatelessWidget {
  const CurrentDate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 60,
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: secondaryColor,
          )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            DateFormat.MMM('ar').format(DateTime.now()),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          ),
          Text(
            DateFormat.d('ar').format(DateTime.now()),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          ),
          Text(
            DateFormat.E('ar').format(DateTime.now()),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
