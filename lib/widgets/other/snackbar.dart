import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:workflow/theme/colors.dart';

snackBarWidget(context, text, icon, iconcolor) {
  return showFlash(
      context: context,
      duration: const Duration(seconds: 2),
      persistent: true,
      builder: (_, controller) {
        return Flash(
          margin: EdgeInsets.symmetric(horizontal: 20),
          borderRadius: BorderRadius.circular(20),
          controller: controller,
          backgroundColor: fillColor,
          barrierBlur: 13.0,
          barrierColor: Colors.black38,
          barrierDismissible: true,
          behavior: FlashBehavior.floating,
          position: FlashPosition.top,
          child: FlashBar(
            icon: Icon(icon, color: mainColor),
            content: Text(
              text,
              style: TextStyle(
                  fontSize: 12,
                  color: mainColor,
                  overflow: TextOverflow.ellipsis),
            ),
          ),
        );
      });
}
