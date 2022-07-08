import 'dart:ui';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:workflow/theme/colors.dart';

const colors = [
  fillColor,
  Color(0xFFA4DFDC),
  Color(0xFFF2BBE0),
  Color(0xFFF4E8BA),
  Color(0xFFBECAF6),
  Color(0xFFF9D2C2),
  Color(0xFFBEDFAE),
  Color(0xFFB1CFE4),
  Color(0xFFF0C1CA),
  Color(0xFFD5B7E4),
];

Color getUserAvatarNameColor(types.User user) {
  final index = user.id.hashCode % colors.length;
  return colors[index];
}

String getUserName(types.User user) =>
    '${user.firstName} ${user.lastName}'.trim();
