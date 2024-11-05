import 'package:adams_county_scheduler/logical_interface/bloc/auth/auth_bloc.dart';
import 'package:adams_county_scheduler/logical_interface/bloc/careers/careers_bloc.dart';
import 'package:adams_county_scheduler/logical_interface/bloc/schools/schools_bloc.dart';
import 'package:adams_county_scheduler/logical_interface/bloc/students/students_bloc.dart';
import 'package:adams_county_scheduler/logical_interface/cubit/home_navigation/home_navigation_cubit.dart';
import 'package:adams_county_scheduler/utilities/colors/ac_colors.dart';
import 'package:adams_county_scheduler/utilities/navigation_items/navigation_items.dart';
import 'package:collapsible_sidebar/collapsible_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utilities/routes/routes.dart';

/// This is the home page of the application
/// {@category Home}
/// {@subCategory User Interface}
///
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    context.read<SchoolsBloc>().add(LoadSchools());
    context.read<CareersBloc>().add(LoadCareers());
    context.read<StudentsBloc>().add(LoadStudents());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is SignedOut) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.of(context).pushReplacementNamed(Routes.signInPage);
        }
      },
      builder: (context, state) {
        return BlocBuilder<HomeNavigationCubit, HomeNavigationState>(
          builder: (context, navigationState) {
            return Scaffold(
              body: CollapsibleSidebar(
                selectedIconBox: ACColors.secondaryColor,
                sidebarBoxShadow: const [],
                selectedIconColor: Theme.of(context).colorScheme.onSurface,
                backgroundColor: Theme.of(context).colorScheme.surface,
                avatarImg: (state.currentUser?.imageUrl.isEmpty ?? true)
                    ? null
                    : NetworkImage(state.currentUser?.imageUrl ?? ''),
                avatarBackgroundColor: ACColors.secondaryColor,
                title: state.currentUser != null &&
                        state.currentUser!.displayName.isEmpty
                    ? 'User'
                    : state.currentUser?.displayName ??
                        state.currentUser?.email ??
                        'User',
                items: getNavigationItems(
                  currentUser: state.currentUser,
                  navigationState: navigationState,
                  updateIndex: (index) => context
                      .read<HomeNavigationCubit>()
                      .updateIndex(index: index),
                ),
                body:
                    homePages.children.elementAt(navigationState.selectedIndex),
              ),
            );
          },
        );
      },
    );
  }
}
