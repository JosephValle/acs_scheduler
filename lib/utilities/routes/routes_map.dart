import 'package:adams_county_scheduler/user_interface/bulk_student_upload/bulk_student_upload_page.dart';
import 'package:adams_county_scheduler/user_interface/career_management/career_management.dart';
import 'package:adams_county_scheduler/user_interface/room_creation/room_creation_page.dart';
import 'package:adams_county_scheduler/user_interface/scheduler/scheduler_page.dart';
import 'package:adams_county_scheduler/user_interface/school_creation/school_creation_page.dart';
import 'package:adams_county_scheduler/user_interface/school_detail/school_detail_page.dart';
import 'package:adams_county_scheduler/utilities/routes/routes.dart';
import 'package:flutter/material.dart';

import '../../user_interface/career_creation/career_creation_page.dart';
import '../../user_interface/home/home_page.dart';
import '../../user_interface/sign_in/sign_in_page.dart';
import '../../user_interface/student_creation/student_creation_page.dart';

/// This maps all of our route names into a map usable for the main application
///
/// ***This has a static constructor and can be called as Routes.routesMap***
///
/// {@category Utilities}
/// {@subCategory Routing}
class RoutesMap {
  RoutesMap._();

  static final Map<String, Widget Function(BuildContext)> routesMap = {
    Routes.homePage: (context) => const HomePage(),
    Routes.signInPage: (context) => const SignInPage(),
    Routes.schoolCreationPage: (context) => const SchoolCreationPage(),
    Routes.careerCreationPage: (context) => const CareerCreationPage(),
    Routes.studentCreationPage: (context) => const StudentCreationPage(),
    Routes.bulkStudentUploadPage: (context) => const BulkStudentUploadPage(),
    Routes.schedulerPage: (context) => const SchedulerPage(),

  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.schoolDetailPage:
        {
          SchoolDetailPageArgs args =
              settings.arguments as SchoolDetailPageArgs;

          return MaterialPageRoute(
            builder: (context) => SchoolDetailPage(school: args.school),
            settings: settings,
          );
        }
      case Routes.careerManagementPage:
        {
          CareerManagementArgs args =
              settings.arguments as CareerManagementArgs;

          return MaterialPageRoute(
            builder: (context) => CareerManagement(
                schoolId: args.schoolId, schoolName: args.schoolName,),
            settings: settings,
          );
        }
      case Routes.roomCreationPage:
        {
          RoomCreationPageArgs args =
              settings.arguments as RoomCreationPageArgs;

          return MaterialPageRoute(
            builder: (context) => RoomCreationPage(schoolId: args.schoolId),
            settings: settings,
          );
        }
      default:
        {
          return null;
        }
    }
  }
}
