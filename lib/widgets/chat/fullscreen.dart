import 'dart:io';

import 'package:flutter/material.dart';
import 'package:workflow/theme/colors.dart';

class FullScreen extends StatefulWidget {
  final String url;
  const FullScreen({Key? key, required this.url}) : super(key: key);

  @override
  _FullScreenState createState() => _FullScreenState();
}

class _FullScreenState extends State<FullScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      backgroundColor: backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Hero(
            tag: 'image',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(widget.url),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
