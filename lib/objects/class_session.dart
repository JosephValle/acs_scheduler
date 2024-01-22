import 'package:adams_county_scheduler/objects/career.dart';
import 'package:adams_county_scheduler/objects/student.dart';
import 'package:adams_county_scheduler/objects/time_session.dart';

class ClassSession {
  final String uniqueId;
  final Career career;
  final TimeSession timeSession;
  List<Student> students;

  ClassSession({
    required this.uniqueId,
    required this.timeSession,
    required this.career,
    required this.students,
  });

  bool get isFull => students.length >= career.maxClassSize;
}
