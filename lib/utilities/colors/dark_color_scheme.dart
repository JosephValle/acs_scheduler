import 'package:adams_county_scheduler/utilities/colors/ac_colors.dart';
import 'package:flutter/material.dart';

/// The default dark color scheme of the app
///
/// {@category Utilities}
/// {@subCategory User Interface}
ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: ACColors.primaryColor,
  onPrimary: Colors.white,
  secondary: ACColors.secondaryColor,
  onSecondary: Colors.black,
  error: Colors.red,
  onError: Colors.white,
  surface: Colors.grey.withValues(alpha: .4),
  onSurface: Colors.white,
);
