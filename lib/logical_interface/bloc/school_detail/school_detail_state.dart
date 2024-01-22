part of 'school_detail_bloc.dart';

@immutable
abstract class SchoolDetailState {
  final List<Career> careers;

  final List<Student> students;

  final List<Room> rooms;

  final String schoolId;

  const SchoolDetailState(
      {required this.careers,
      required this.rooms,
      required this.students,
      required this.schoolId,});
}

class SchoolDetailInitial extends SchoolDetailState {
  const SchoolDetailInitial(
      {required super.careers,
      required super.rooms,
      required super.students,
      required super.schoolId,});
}

class SchoolInformationLoading extends SchoolDetailState {
  const SchoolInformationLoading(
      {required super.careers,
      required super.rooms,
      required super.students,
      required super.schoolId,});
}

class SchoolInformationLoaded extends SchoolDetailState {
  const SchoolInformationLoaded(
      {required super.careers,
      required super.rooms,
      required super.students,
      required super.schoolId,});
}

class SchoolRoomsAdded extends SchoolDetailState {
  const SchoolRoomsAdded(
      {required super.careers,
      required super.rooms,
      required super.students,
      required super.schoolId,});
}

class SchoolStudentsAdded extends SchoolDetailState {
  const SchoolStudentsAdded(
      {required super.careers,
      required super.rooms,
      required super.students,
      required super.schoolId,});
}

class SchoolCareersLoaded extends SchoolDetailState {
  const SchoolCareersLoaded(
      {required super.careers,
      required super.rooms,
      required super.students,
      required super.schoolId,});
}
