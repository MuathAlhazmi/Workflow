import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:workflow/helpers/responsive.dart';
import 'package:workflow/theme/colors.dart';

class SettingsList extends StatelessWidget {
  final String title;
  final IconData iconData;
  final VoidCallback? onTap;
  const SettingsList({this.onTap, required this.iconData, required this.title});

  @override
  Widget build(BuildContext context) {
    return Responsive.isMobile(context)
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  primary: CupertinoColors.tertiarySystemFill,
                  padding: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 10,
                  ),
                  onPrimary: Colors.white38,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: onTap ?? () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          iconData,
                          color: fillColor,
                        ),
                        VerticalDivider(
                          color: Colors.transparent,
                        ),
                        Text(
                          '$title',
                          style: TextStyle(
                            fontSize: 14,
                            color: fillColor,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: fillColor,
                    ),
                  ],
                ),
              ),
            ),
          )
        : Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  iconData,
                  color: mainColor,
                ),
                Text(
                  '$title',
                  style: TextStyle(
                    fontSize: 14,
                    color: mainColor,
                  ),
                ),
              ],
            ),
          );
  }
}
