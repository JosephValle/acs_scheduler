import 'package:flutter/material.dart';



/// This class contains custom colors for our application and maps them to be material
///
/// ***This has a static constructor and can be called as ACColors.primaryColor***
///
/// {@category Utilities}
/// {@subCategory User Interface}
class ACColors {
  ACColors._();

  static MaterialColor primaryColor =
      MaterialColor(0xff00578B, _primaryColorMap);

  static final Map<int, Color> _primaryColorMap = {
    50: const Color.fromRGBO(0, 87, 139, .1),
    100: const Color.fromRGBO(0, 87, 139, .2),
    200: const Color.fromRGBO(0, 87, 139, .3),
    300: const Color.fromRGBO(0, 87, 139, .4),
    400: const Color.fromRGBO(0, 87, 139, .5),
    500: const Color.fromRGBO(0, 87, 139, .6),
    600: const Color.fromRGBO(0, 87, 139, .7),
    700: const Color.fromRGBO(0, 87, 139, .8),
    800: const Color.fromRGBO(0, 87, 139, .9),
    900: const Color.fromRGBO(0, 87, 139, 1),
  };

  static MaterialColor secondaryColor =
      MaterialColor(0xffFFC300, _secondaryColorMap);

  static final Map<int, Color> _secondaryColorMap = {
    50: const Color.fromRGBO(255, 195, 0, .1),
    100: const Color.fromRGBO(255, 195, 0, .2),
    200: const Color.fromRGBO(255, 195, 0, .3),
    300: const Color.fromRGBO(255, 195, 0, .4),
    400: const Color.fromRGBO(255, 195, 0, .5),
    500: const Color.fromRGBO(255, 195, 0, .6),
    600: const Color.fromRGBO(255, 195, 0, .7),
    700: const Color.fromRGBO(255, 195, 0, .8),
    800: const Color.fromRGBO(255, 195, 0, .9),
    900: const Color.fromRGBO(255, 195, 0, 1),
  };

//D9EBB5
}
