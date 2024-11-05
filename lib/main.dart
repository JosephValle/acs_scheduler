
import 'package:adams_county_scheduler/logical_interface/bloc/careers/careers_bloc.dart';
import 'package:adams_county_scheduler/logical_interface/bloc/scheduler/scheduler_bloc.dart';
import 'package:adams_county_scheduler/logical_interface/bloc/school_detail/school_detail_bloc.dart';
import 'package:adams_county_scheduler/logical_interface/bloc/schools/schools_bloc.dart';
import 'package:adams_county_scheduler/logical_interface/bloc/students/students_bloc.dart';
import 'package:adams_county_scheduler/logical_interface/cubit/home_navigation/home_navigation_cubit.dart';
import 'package:adams_county_scheduler/logical_interface/cubit/student_sort/student_sort_cubit.dart';
import 'package:adams_county_scheduler/network_interface/repositories/careers/careers_repository.dart';
import 'package:adams_county_scheduler/network_interface/repositories/scheduler/schedule_repository.dart';
import 'package:adams_county_scheduler/network_interface/repositories/school_detail/school_detail_repository.dart';
import 'package:adams_county_scheduler/network_interface/repositories/schools/schools_repository.dart';
import 'package:adams_county_scheduler/network_interface/repositories/students/students_repository.dart';
import 'package:adams_county_scheduler/objects/profile.dart';
import 'package:adams_county_scheduler/utilities/colors/dark_color_scheme.dart';
import 'package:adams_county_scheduler/utilities/colors/light_color_scheme.dart';
import 'package:adams_county_scheduler/utilities/routes/routes.dart';
import 'package:adams_county_scheduler/utilities/routes/routes_map.dart';
import 'package:adams_county_scheduler/utilities/theme/tab_bar.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';

import 'firebase_options.dart';
import 'logical_interface/bloc/auth/auth_bloc.dart';
import 'network_interface/repositories/auth/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter('cache');

  await AppTrackingTransparency.requestTrackingAuthorization();

  Hive.registerAdapter(
    ProfileAdapter(),
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //
  // await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(kDebugMode);
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  //
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //   return true;
  // };

  User? user = FirebaseAuth.instance.currentUser;

  runApp(
    AdamsCountScheduler(
      currentUser: user,
    ),
  );
}

class AdamsCountScheduler extends StatelessWidget {
  final User? currentUser;

  const AdamsCountScheduler({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(),
        ),
        RepositoryProvider<SchoolsRepository>(
          create: (context) => SchoolsRepository(),
        ),
        RepositoryProvider<CareersRepository>(
          create: (context) => CareersRepository(),
        ),
        RepositoryProvider<SchoolDetailRepository>(
          create: (context) => SchoolDetailRepository(),
        ),
        RepositoryProvider<StudentsRepository>(
          create: (context) => StudentsRepository(),
        ),
        RepositoryProvider<ScheduleRepository>(
          create: (context) => ScheduleRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
              currentUser: currentUser,
            ),
          ),
          BlocProvider<HomeNavigationCubit>(
            create: (context) => HomeNavigationCubit(),
          ),
          BlocProvider<SchoolsBloc>(
            create: (context) => SchoolsBloc(
              schoolsRepository: context.read<SchoolsRepository>(),
            ),
          ),
          BlocProvider<CareersBloc>(
            create: (context) => CareersBloc(
              careersRepository: context.read<CareersRepository>(),
            ),
          ),
          BlocProvider<SchedulerBloc>(
            create: (context) => SchedulerBloc(
              scheduleRepository: context.read<ScheduleRepository>(),
            ),
          ),
          BlocProvider<SchoolDetailBloc>(
            create: (context) => SchoolDetailBloc(
              schoolDetailRepository: context.read<SchoolDetailRepository>(),
              studentsRepository: context.read<StudentsRepository>(),
            ),
          ),
          BlocProvider<StudentsBloc>(
            create: (context) => StudentsBloc(
              studentsRepository: context.read<StudentsRepository>(),
            ),
          ),
          BlocProvider<StudentSortCubit>(
            create: (context) => StudentSortCubit(),
          ),
        ],
        child: MaterialApp(
          title: 'Career Scheduler',
          onGenerateRoute: RoutesMap.onGenerateRoute,
          theme: ThemeData(
            colorScheme: lightColorScheme,
            tabBarTheme: LightTabBarTheme(),
          ),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme,
            tabBarTheme: DarkTabBarTheme(),
          ),
          routes: RoutesMap.routesMap,
          initialRoute:
              currentUser == null ? Routes.signInPage : Routes.homePage,
        ),
      ),
    );
  }
}
