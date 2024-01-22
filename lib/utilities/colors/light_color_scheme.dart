import 'package:adams_county_scheduler/utilities/colors/ac_colors.dart';
import 'package:flutter/material.dart';

/// The default light color scheme of the app
///
/// {@category Utilities}
/// {@subCategory User Interface}
ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: ACColors.primaryColor,
  onPrimary: Colors.black,
  secondary: ACColors.secondaryColor,
  onSecondary: Colors.black,
  error: Colors.red,
  onError: Colors.white,
  background: Colors.white,
  onBackground: Colors.black,
  surface: const Color(0xFFF0F0F0),
  onSurface: Colors.black,
);
