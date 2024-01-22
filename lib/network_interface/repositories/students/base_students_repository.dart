import '../../../objects/career_priority.dart';
import '../../../objects/student.dart';

abstract class BaseStudentsRepository {
  ///Get all students of a school
  ///
  /// [schoolId] is the id of the school to query for
  Future<List<Student>> getStudentBySchool({required String schoolId});

  /// Get's all students
  Future<List<Student>> getStudents();

  ///Create a new student
  ///
  /// [firstName] is the given name of a student
  /// [lastName] is the family name of the student
  /// [careerPriority] is the [CareerPriority] the student has created
  /// [school] is the readable name of the school they attend
  /// [schoolId] is the id of the school they attend
  /// [grade] is the grade of the student
  Future<Student> createStudent({
    required String firstName,
    required String lastName,
    required CareerPriority careerPriority,
    required String school,
    required String schoolId,
    required int grade,
  });

  Future<String?> getSchoolIdByName({required String schoolName});
}
