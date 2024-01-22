import 'package:adams_county_scheduler/utilities/colors/ac_colors.dart';
import 'package:flutter/material.dart';

class LightTabBarTheme extends TabBarTheme {
  @override
  Color? get labelColor => ACColors.secondaryColor;

  @override
  Color? get unselectedLabelColor => ACColors.primaryColor.withOpacity(.4);

  @override
  Color? get indicatorColor => ACColors.primaryColor;

  @override
  Color? get dividerColor => ACColors.primaryColor;
}

class DarkTabBarTheme extends TabBarTheme {
  @override
  Color? get labelColor => ACColors.primaryColor;

  @override
  Color? get unselectedLabelColor => ACColors.secondaryColor.withOpacity(.4);

  @override
  Color? get indicatorColor => ACColors.secondaryColor;

  @override
  Color? get dividerColor => ACColors.secondaryColor;
}
