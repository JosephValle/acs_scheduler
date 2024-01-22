import 'package:adams_county_scheduler/objects/student.dart';

class ExportCareerSchedule {
  final String career;
  final String room;
  final int excelId;
  List<int> sessionCounts;
  List<List<Student>> students;

  ExportCareerSchedule({
    required this.excelId,
    required this.career,
    required this.room,
    required this.sessionCounts,
    required this.students,
  });

  Map<String, dynamic> toJson() {
    return {
      'Id': excelId,
      'Career': career,
      'Room': room,
      'Session Counts': sessionCounts,
    };
  }
}
