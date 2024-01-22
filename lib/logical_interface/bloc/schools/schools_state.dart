part of 'schools_bloc.dart';

@immutable
abstract class SchoolsState {
  final List<School> schools;

  const SchoolsState({required this.schools});
}

class SchoolsInitial extends SchoolsState {
  const SchoolsInitial({required super.schools});
}

class ImageUploadProgressUpdated extends SchoolsState {
  final double progress;

  const ImageUploadProgressUpdated({
    required super.schools,
    required this.progress,
  });
}

class SchoolsLoaded extends SchoolsState {
  const SchoolsLoaded({required super.schools});
}

class SchoolCreated extends SchoolsState {
  const SchoolCreated({required super.schools});
}
