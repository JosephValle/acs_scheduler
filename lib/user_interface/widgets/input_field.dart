import 'package:flutter/material.dart';

/// This is a heavily reused widget. This widget creates an input field that we can use to match our UI and complete some basic pieces of the textfield interfacing
///
/// [hintText] is the text a user should see before anything is entered
/// [suffixIcon] is a trailing item on the field
/// [controller] is the [TextEditingController] we want to use
/// [label] is the label of the field and displays as a title
/// [prefixIcon] is an item to show in front of the field
/// [obscure] indicates if the text should be human readable
/// [onTap] is an optional function to use when tapping the field instead of typing
/// [validator] can be passed if form validation is used
/// [onSubmitted] can be passed if we want the done button to do something
/// [maxLines] is the max amount of lines this can expand to
/// [minLines] is the smallest amount of lines we want visible to the user
/// [maxCharacters] is used for a character limit on the field
/// [currentCharacters] is the current character count entered
/// [keyboardType] can change our input keyboard format
/// [textStyle] changes the style of the user entered text
/// [padding] changes the child padding of the container
/// [fillColor] will change the background color
/// [enabled] changes if it is clickable or not
/// [onChanged] can be used for an event on text changed
///
/// {@category Widgets}
/// {@subCategory User Interface}
class InputField extends StatelessWidget {
  final String hintText;
  final Widget? suffixIcon;
  final TextEditingController controller;
  final String? label;
  final Widget? prefixIcon;
  final bool obscure;
  final Function? onTap;
  final String? Function(String?)? validator;
  final String? Function(String?)? onSubmitted;
  final int? maxLines;
  final int? minLines;
  final int? maxCharacters;
  final int? currentCharacters;
  final TextInputType? keyboardType;
  final TextStyle? textStyle;
  final EdgeInsets? padding;
  final Color? fillColor;
  final bool? enabled;

  final Function(String)? onChanged;

  const InputField({
    super.key,
    required this.hintText,
    this.suffixIcon,
    required this.controller,
    this.label,
    this.prefixIcon,
    this.obscure = false,
    this.onTap,
    this.validator,
    this.maxCharacters,
    this.maxLines,
    this.minLines,
    this.currentCharacters,
    this.keyboardType,
    this.onChanged,
    this.textStyle,
    this.padding,
    this.fillColor,
    this.onSubmitted,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label == null
            ? Container()
            : Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(label!),
        ),
        Padding(
          padding: padding?? const EdgeInsets.all(8.0),
          child: TextFormField(
            enabled: enabled,
            style: textStyle,
            onChanged: onChanged,
            keyboardType: keyboardType,
            maxLines: maxLines ?? 1,
            minLines: minLines,
            maxLength: maxCharacters,
            validator: validator,
            onTap: () => onTap?.call(),
            controller: controller,
            obscureText: obscure,
            onFieldSubmitted: (value) => onSubmitted?.call(value),
            decoration: InputDecoration(
              contentPadding: padding,
              fillColor: fillColor,
              hintText: hintText,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
            ),
          ),
        ),
      ],
    );
  }
}
