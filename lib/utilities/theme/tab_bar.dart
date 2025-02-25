import 'package:adams_county_scheduler/utilities/colors/ac_colors.dart';
import 'package:flutter/material.dart';

class LightTabBarTheme extends TabBarTheme {
  const LightTabBarTheme({super.key});

  @override
  Color? get labelColor => ACColors.secondaryColor;

  @override
  Color? get unselectedLabelColor =>
      ACColors.primaryColor.withValues(alpha: .4);

  @override
  Color? get indicatorColor => ACColors.primaryColor;

  @override
  Color? get dividerColor => ACColors.primaryColor;
}

class DarkTabBarTheme extends TabBarTheme {
  const DarkTabBarTheme({super.key});

  @override
  Color? get labelColor => ACColors.primaryColor;

  @override
  Color? get unselectedLabelColor =>
      ACColors.secondaryColor.withValues(alpha: .4);

  @override
  Color? get indicatorColor => ACColors.secondaryColor;

  @override
  Color? get dividerColor => ACColors.secondaryColor;
}
