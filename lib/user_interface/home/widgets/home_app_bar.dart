import 'package:adams_county_scheduler/user_interface/widgets/colored_container.dart';
import 'package:adams_county_scheduler/user_interface/widgets/profile_avatar.dart';
import 'package:adams_county_scheduler/utilities/colors/ac_colors.dart';
import 'package:flutter/material.dart';

///This is a custom app bar for the home page
///
/// [displayName] is the name of the currentUser
/// [imageUrl] is the image item for the current user
class HomeAppBar extends AppBar {
  final String displayName;
  final String imageUrl;
  final String userId;

  final Function() onSignOut;

  HomeAppBar(
      {super.key,
      required this.imageUrl,
      required this.displayName,
      required this.userId,
      required super.leadingWidth,
      required this.onSignOut,});

  @override
  Widget? get leading => Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ProfileAvatar(imageUrl: imageUrl, userId: userId),
          ),
          Text(displayName),
        ],
      );

  @override
  Widget? get title => const Text('Career Day Scheduler');

  @override
  bool get automaticallyImplyLeading => false;

  @override
  // TODO: implement actions
  List<Widget>? get actions => [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ColoredContainer(
            onTap: onSignOut,
            backgroundColor: ACColors.secondaryColor,
            child: const Text('Sign Out'),
          ),
        ),
      ];
}
