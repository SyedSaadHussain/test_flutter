import 'dart:ui';
import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // this basically makes it so you can't instantiate this class
  static const Color primary= Color(0xFF1b6444);
  static const Color primaryContainer= Color(0xFF8cd177);
  static const Color onPrimary= Color(0xffc9e5d8);
  static const Color secondly= Color(0xffd0db84);
  static const Color flushColor= Color(0xff74a063);
  static const Color backgroundColor= Color(0xFFfbfbfb);
  static const Color formField= Color(0xFFf1f1f1);
  static const Color formDisabledField= Color(0xFFe6e3e3);
  static const Color body= Color(0xFFf6e6e6e);

  static const Color formText= Color(0xff83a1c3);

  static const Color bodyText= Color(0xff818181);



  static const Color onSecondly= Color(0xfffbffde);
  static const Color primaryText= Color(0xFFd0d4ee);
  static const Color gray= Color(0xFF616060);
  static const Color hint= Color(0xFFc1c1c1);

  static const Color other= Color(0xFF363689);
  static const Color success= Color(0xFF53af43);
  static const Color danger= Color(0xFFd93025);
  static const Color info= Color(0xFF129eaf);
  static const Color warning= Color(0xFFe37400);
  static const Color defaultColor= Color(0xFF6c8492);
}

// Mapping Odoo classes to colors
final Map<int, Color> OdooColor = {
  1: Color(0xFFF06050),
  2: Color(0xFFF4A460),
  3: Color(0xFFF7CD1F),
  4: Color(0xFF6CC1ED),
  5: Color(0xFF814968),
  6: Color(0xFFEB7E7F),
  7: Color(0xFF2C8397),
  8: Color(0xFF475577),
  9: Color(0xFFD6145F),
  10: Color(0xFF30C381),
};