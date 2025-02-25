import 'package:adams_county_scheduler/network_interface/api_clients/students_api_client.dart';
import 'package:adams_county_scheduler/network_interface/repositories/students/base_students_repository.dart';
import 'package:adams_county_scheduler/objects/career_priority.dart';
import 'package:adams_county_scheduler/objects/student.dart';

class StudentsRepository implements BaseStudentsRepository {
  final StudentApiClient _studentsApiClient = StudentApiClient();

  @override
  Future<Student> createStudent({
    required String firstName,
    required String lastName,
    required CareerPriority careerPriority,
    required String school,
    required String schoolId,
    required int grade,
  }) async {
    return await _studentsApiClient.createStudent(
      firstName: firstName,
      lastName: lastName,
      careerPriority: careerPriority,
      school: school,
      schoolId: schoolId,
      grade: grade,
    );
  }

  @override
  Future<List<Student>> getStudentBySchool({required String schoolId}) async {
    return await _studentsApiClient.getStudentBySchool(schoolId: schoolId);
  }

  @override
  Future<List<Student>> getStudents() async {
    return await _studentsApiClient.getStudents();
  }

  @override
  Future<String?> getSchoolIdByName({required String schoolName}) async {
    try {
      return await _studentsApiClient.getSchoolIdByName(schoolName: schoolName);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearAllStudents() async {
    return await _studentsApiClient.clearAllStudents();
  }

  Future<Student> editStudent({
    required String id,
    required String firstName,
    required String lastName,
    required CareerPriority careerPriority,
    required String school,
    required String schoolId,
    required int grade,
  }) async {
    return await _studentsApiClient.editStudent(
      id: id,
      firstName: firstName,
      lastName: lastName,
      careerPriority: careerPriority,
      school: school,
      schoolId: schoolId,
      grade: grade,
    );
  }
}
