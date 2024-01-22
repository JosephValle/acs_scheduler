import 'package:adams_county_scheduler/logical_interface/bloc/auth/auth_bloc.dart';
import 'package:adams_county_scheduler/user_interface/widgets/colored_container.dart';
import 'package:adams_county_scheduler/user_interface/widgets/svg_icon.dart';
import 'package:adams_county_scheduler/utilities/colors/ac_colors.dart';
import 'package:adams_county_scheduler/utilities/theme/colored_container_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../../utilities/routes/routes.dart';

/// This is the sign in page of the application
/// {@category SignIn}
/// {@subCategory User Interface}
class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is SignInSuccess) {
          Navigator.of(context).pushReplacementNamed(Routes.homePage);
        }
      },
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgIcon(
                name: 'adams_county',
                color: null,
                size: MediaQuery.of(context).size.width / 4,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: ColoredContainer(
                  onTap: () {
                    context.read<AuthBloc>().add(SignIn());
                  },
                  backgroundColor: ACColors.primaryColor,
                  child: Text(
                    'Sign In',
                    style: ColoredContainerTextStyle(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
