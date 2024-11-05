import 'package:adams_county_scheduler/user_interface/widgets/colored_container.dart';
import 'package:adams_county_scheduler/user_interface/widgets/profile_avatar.dart';
import 'package:adams_county_scheduler/utilities/colors/ac_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logical_interface/bloc/auth/auth_bloc.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ProfileAvatar(
                        imageUrl: state.currentUser?.imageUrl ?? '',
                        userId: state.currentUser?.id ?? '',
                        radius: MediaQuery.of(context).size.width / 30,),
                  ),
                  Text(
                    state.currentUser?.displayName ?? '',
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width / 30,),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Email: ${state.currentUser?.email ?? ""}"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("AppId: ${state.currentUser?.id ?? ""}"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    "Permissions: ${state.currentUser?.isAdmin ?? false ? "Admin" : "Standard"}",),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ColoredContainer(
                  onTap: () => context.read<AuthBloc>().add(SignOut()),
                  backgroundColor: ACColors.secondaryColor,
                  child: Text(
                    'Sign Out',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
