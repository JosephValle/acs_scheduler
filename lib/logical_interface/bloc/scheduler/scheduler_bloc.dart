import 'package:adams_county_scheduler/network_interface/repositories/scheduler/schedule_repository.dart';
import 'package:adams_county_scheduler/objects/report.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import '../../../network_interface/api_clients/scheduler_api_client.dart';
import '../../../objects/time_session.dart';

part 'scheduler_event.dart';

part 'scheduler_state.dart';

class SchedulerBloc extends Bloc<SchedulerEvent, SchedulerState> {
  final ScheduleRepository _scheduleRepository;
  List<TimeSession> sessions = [];
  List<ReportLink> reports = [];

  SchedulerBloc({required ScheduleRepository scheduleRepository})
      : _scheduleRepository = scheduleRepository,
        super(SchedulerLoading()) {
    on<InitScheduler>((event, emit) async {
      try {
        emit(SchedulerLoading());
        sessions = await SchedulerApiClient().getAllSessions();
        sessions.sort((a, b) => a.time.compareTo(b.time));
        reports = await SchedulerApiClient().getAllReports();
        emit(SchedulerLoaded());
      } catch (e) {
        debugPrint('Error Getting Scheduler: $e');
        if (e is Error) {
          debugPrint('${e.stackTrace}');
        }
        emit(SchedulerError(error: e.toString()));
      }
    });

    on<GenerateSchedule>((event, emit) async {
      try {
        emit(SchedulerLoading());
        await _scheduleRepository.generateSchedule(event.isAm);
        reports = await SchedulerApiClient().getAllReports();
        emit(SchedulerLoaded());
      } catch (e) {
        debugPrint('Error Generating Schedule: $e');
        if (e is Error) {
          debugPrint('${e.stackTrace}');
        }
        emit(SchedulerError(error: e.toString()));
      }
    });

    on<AddSession>((event, emit) async {
      emit(SchedulerLoading());
      sessions.add(event.session);
      sessions.sort((a, b) => a.time.compareTo(b.time));
      emit(SchedulerLoaded());
    });

    on<RemoveSession>((event, emit) async {
      emit(SchedulerLoading());
      sessions.removeAt(event.index);
      emit(SchedulerLoaded());
    });
  }
}
