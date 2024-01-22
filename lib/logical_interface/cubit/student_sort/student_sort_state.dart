part of 'student_sort_cubit.dart';

@immutable
abstract class StudentSortState {
  final int index;
  final bool ascending;

  const StudentSortState({required this.ascending, required this.index});
}

class StudentSortInitial extends StudentSortState {
  const StudentSortInitial({required super.ascending, required super.index});
}

class StudentSortUpdated extends StudentSortState {
  const StudentSortUpdated({required super.ascending, required super.index});
}
