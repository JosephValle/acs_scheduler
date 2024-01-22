part of 'scheduler_bloc.dart';

@immutable
abstract class SchedulerEvent {}

class InitScheduler extends SchedulerEvent {}

class CreateSession extends SchedulerEvent {
  final DateTime time;

  CreateSession({
    required this.time,
  });
}

class GenerateSchedule extends SchedulerEvent {
  final bool isAm;

  GenerateSchedule({
    required this.isAm,
  });
}

class RemoveSession extends SchedulerEvent {
  final int index;

  RemoveSession({required this.index});
}

class AddSession extends SchedulerEvent {
  final TimeSession session;

  AddSession({required this.session});
}
