import 'package:flutter/material.dart';



/// This is a heavily reused widget. This widget creates a container with a lot of default values.
/// This widget is used in a lot of the app because of it's versatility.
///
/// [backgroundColor] is the [Color] you want the container to be
/// [child] is the [Widget] you want to display in it
/// [childPadding] is an edge inset value of how far from the border you want the children
/// [borderRadius] is a value that we use to set the circular radius of the widget
/// [onTap] is a method you want to call when clicking on it
/// [width] is an optional width
/// [height] is an optional height
/// [borderRadiusOnly] allows you to apply customer [BorderRadius] objects instead of a circular
///
/// {@category Widgets}
/// {@subCategory User Interface}
class ColoredContainer extends StatelessWidget {
  final Color backgroundColor;
  final Widget child;
  final EdgeInsets childPadding;
  final double borderRadius;
  final void Function()? onTap;
  final double? width;
  final double? height;
  final BorderRadius? borderRadiusOnly;

  final Color? borderColor;

  const ColoredContainer({
    super.key,
    required this.backgroundColor,
    this.childPadding = const EdgeInsets.all(8),
    this.borderRadius = 10,
    this.onTap,
    required this.child,
    this.width,
    this.height,
    this.borderRadiusOnly,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap?.call(),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            border: borderColor == null ? null : Border.all(color: borderColor!),
            borderRadius: borderRadiusOnly ?? BorderRadius.circular(borderRadius),
            color: backgroundColor,),
        child: Padding(
          padding: childPadding,
          child: Center(child: child),
        ),
      ),
    );
  }
}
