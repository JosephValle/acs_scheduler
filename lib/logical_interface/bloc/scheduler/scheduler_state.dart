part of 'scheduler_bloc.dart';

@immutable
abstract class SchedulerState {
  // TODO: List of student schedules
  // TODO: List of career schedules
  // TODO: List of Current Session Times
  // TODO: Object witjh document Urls!
}

class SchedulerLoading extends SchedulerState {}

class SchedulerError extends SchedulerState {
  final String error;

  SchedulerError({
    required this.error,
  });
}

class SchedulerLoaded extends SchedulerState {}
