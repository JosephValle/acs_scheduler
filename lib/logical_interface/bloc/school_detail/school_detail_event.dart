part of 'school_detail_bloc.dart';

@immutable
abstract class SchoolDetailEvent {
  final String schoolId;

  const SchoolDetailEvent({required this.schoolId});
}

class LoadSchoolDetails extends SchoolDetailEvent {
  const LoadSchoolDetails({required super.schoolId});
}

class AddRoom extends SchoolDetailEvent {
  final String name;
  final String building;
  final int maxSize;

  final int? minSize;

  const AddRoom({
    required super.schoolId,
    required this.maxSize,
    required this.building,
    required this.minSize,
    required this.name,
  });
}

class RemoveCareer extends SchoolDetailEvent {
  final String careerId;

  const RemoveCareer({required this.careerId, required super.schoolId});
}

class AddCareer extends SchoolDetailEvent {
  final Career career;

  const AddCareer({required super.schoolId, required this.career});
}

class AddStudent extends SchoolDetailEvent {
  final Student student;

  const AddStudent({required super.schoolId, required this.student});
}
