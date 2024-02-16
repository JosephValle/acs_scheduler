part of 'students_bloc.dart';

@immutable
abstract class StudentsState {
  final List<Student> students;

  const StudentsState({required this.students});
}

class StudentsInitial extends StudentsState {
  const StudentsInitial({required super.students});
}

class StudentsLoaded extends StudentsState {
  const StudentsLoaded({required super.students});
}

class StudentCreated extends StudentsState {
  const StudentCreated({required super.students});
}

class UploadFinished extends StudentsState {
  final List<String> errors;

  const UploadFinished({required super.students, required this.errors});
}

class BulkUploadStarted extends StudentsState {
  const BulkUploadStarted({required super.students});
}
