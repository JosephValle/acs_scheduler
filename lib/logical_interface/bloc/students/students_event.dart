part of 'students_bloc.dart';

@immutable
abstract class StudentsEvent {}

class LoadStudents extends StudentsEvent {}

class EditStudent extends StudentsEvent {
  final String id;
  final String firstName;
  final String lastName;
  final int grade;
  final String schoolId;
  final String schoolName;
  final CareerPriority priority;

  EditStudent({
    required this.id,
    required this.priority,
    required this.firstName,
    required this.lastName,
    required this.schoolName,
    required this.grade,
    required this.schoolId,
  });
}

class SortStudents extends StudentsEvent {
  final bool ascending;
  final int index;

  SortStudents({required this.index, required this.ascending});
}

class BulkUploadStudents extends StudentsEvent {
  final Sheet sheet;

  BulkUploadStudents({required this.sheet});
}

class ClearAllStudents extends StudentsEvent {}
