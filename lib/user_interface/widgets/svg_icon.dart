import 'package:flutter/material.dart';

/// This is a resuable widget for displaying SVGS
///
/// [name] is the name of the svg. If the file is .../assets/svg/image1.svg you can pass image1
/// [color] is the [Color] we will use to fill the SVG
/// [size] is the height you want the widget to fit to
///
/// {@category Widgets}
/// {@subCategory User Interface}
class SvgIcon extends StatelessWidget {
  final String name;
  final Color? color;
  final double? size;

  const SvgIcon({
    super.key,
    this.size,
    required this.name,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/png/$name.png',
      height: size ?? 20,
      fit: BoxFit.fitHeight,
    );
  }
}
