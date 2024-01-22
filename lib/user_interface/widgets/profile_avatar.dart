import 'package:adams_county_scheduler/utilities/colors/ac_colors.dart';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final String userId;
  final double? radius;

  const ProfileAvatar(
      {super.key, required this.imageUrl, required this.userId, this.radius,});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: ACColors.primaryColor,
      foregroundImage: imageUrl.isEmpty ? null : NetworkImage(imageUrl),
      child: Icon(Icons.person, color: Theme.of(context).colorScheme.onBackground,),
    );
  }
}
