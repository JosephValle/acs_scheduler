import 'package:adams_county_scheduler/objects/class_session.dart';
import 'package:adams_county_scheduler/objects/student.dart';

class StudentSchedule {
  final String uniqueId;
  final Student student;
  List<ClassSession> sessions;
  final int sessionCount;

  StudentSchedule({
    required this.uniqueId,
    required this.sessionCount,
    required this.student,
    required this.sessions,
  });

  bool get isFull => sessions.length >= sessionCount;
}
