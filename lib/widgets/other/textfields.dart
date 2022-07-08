import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:workflow/theme/colors.dart';

class TextFieldWidget extends StatelessWidget {
  final String labeltext;
  final String hinttext;
  final TextEditingController textController;
  const TextFieldWidget({
    required this.labeltext,
    required this.textController,
    required this.hinttext,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
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
        controller: this.textController,
        cursorColor: mainColor,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.transparent, width: 2)),
            disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.transparent, width: 2)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: fillColor, width: 2)),
            focusColor: fillColor,
            hoverColor: fillColor,
            border: InputBorder.none,
            labelText: '${this.labeltext}',
            hintText: '${this.hinttext}',
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
            floatingLabelBehavior: FloatingLabelBehavior.never),
      ),
    );
  }
}
