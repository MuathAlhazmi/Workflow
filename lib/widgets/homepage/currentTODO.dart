import 'package:flutter/material.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:workflow/helpers/responsive.dart';
import 'package:workflow/theme/colors.dart';

class CurrentTODO extends StatelessWidget {
  const CurrentTODO({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width * 0.6
          : MediaQuery.of(context).size.width * 0.4,
      child: ResponsiveGridList(
        desiredItemWidth: 200,
        minSpacing: 10,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'المهام الحالية',
                  style: TextStyle(
                      color: mainColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                Text(
                  '4',
                  style: TextStyle(
                    fontSize: 16,
                    color: mainColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'المهام الحالية',
                  style: TextStyle(
                      color: mainColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                Text(
                  '4',
                  style: TextStyle(
                    fontSize: 16,
                    color: mainColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'المهام الحالية',
                  style: TextStyle(
                      color: mainColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                Text(
                  '4',
                  style: TextStyle(
                    fontSize: 16,
                    color: mainColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
