/// This maps all of our route names to variables to avoid typos
///
/// ***This has a static constructor and can be called as Routes.homePage***
///
/// {@category Utilities}
/// {@subCategory Routing}
class Routes {
  Routes._();

  static const String homePage = '/home';
  static const String signInPage = '/sign_in';
  static const String schoolCreationPage = '/create_school';
  static const String careerCreationPage = '/career_creation_page';
  static const String schoolDetailPage = '/school_detail';
  static const String careerManagementPage = '/career_management';
  static const String roomCreationPage = '/room_creation_page';
  static const String studentCreationPage = '/student_creation_page';
  static const String bulkStudentUploadPage = '/bulk_student_upload_page';
  static const String schedulerPage = '/scheduler_page';
}
