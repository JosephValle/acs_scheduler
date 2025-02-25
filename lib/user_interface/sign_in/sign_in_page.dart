import 'package:adams_county_scheduler/logical_interface/bloc/auth/auth_bloc.dart';
import 'package:adams_county_scheduler/user_interface/sign_in/widgets/reset_password_dialog.dart';
import 'package:adams_county_scheduler/user_interface/widgets/colored_container.dart';
import 'package:adams_county_scheduler/user_interface/widgets/svg_icon.dart';
import 'package:adams_county_scheduler/utilities/colors/ac_colors.dart';
import 'package:adams_county_scheduler/utilities/theme/colored_container_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utilities/routes/routes.dart';

/// This is the sign in page of the application
/// {@category SignIn}
/// {@subCategory User Interface}
class SignInPage extends StatelessWidget {
  SignInPage({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is SignInSuccess) {
          Navigator.of(context).pushReplacementNamed(Routes.homePage);
        }
      },
      child: Scaffold(
        body: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width / 3,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Row(),
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
                  child: TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'email',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                    ),
                    obscureText: true,
                    onFieldSubmitted: (value) {
                      context.read<AuthBloc>().add(
                            SignIn(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                            ),
                          );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: ColoredContainer(
                      onTap: () {
                        context.read<AuthBloc>().add(
                              SignIn(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                              ),
                            );
                      },
                      backgroundColor: ACColors.primaryColor,
                      child: Text(
                        'Sign In',
                        style: ColoredContainerTextStyle(),
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => ResetPasswordDialog(),
                  ),
                  child: const Text(
                    'Reset Password',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
