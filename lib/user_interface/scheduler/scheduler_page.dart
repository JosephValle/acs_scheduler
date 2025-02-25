import 'package:adams_county_scheduler/objects/report.dart';
import 'package:adams_county_scheduler/objects/time_session.dart';
import 'package:adams_county_scheduler/user_interface/scheduler/widgets/create_session_dialog.dart';
import 'package:adams_county_scheduler/user_interface/scheduler/widgets/report_tile.dart';
import 'package:adams_county_scheduler/user_interface/scheduler/widgets/session_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logical_interface/bloc/scheduler/scheduler_bloc.dart';

class SchedulerPage extends StatefulWidget {
  const SchedulerPage({super.key});

  @override
  State<SchedulerPage> createState() => _SchedulerPageState();
}

class _SchedulerPageState extends State<SchedulerPage> {
  bool isMobile = false;
  double screenWidth = 0.0;

  @override
  void initState() {
    context.read<SchedulerBloc>().add(InitScheduler());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    isMobile = screenWidth <= 600;
    return BlocConsumer<SchedulerBloc, SchedulerState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    Flex(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      direction: Axis.horizontal,
                      children: [_buildSessions(), _buildSchedule()],
                    ),
                  ],
                ),
              ),
              if (state is SchedulerLoading)
                ColoredBox(
                  color: Colors.grey.withValues(alpha: .25),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSchedule() {
    final List<ReportLink> reports = context.read<SchedulerBloc>().reports;
    return _buildCardWidget(
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Schedules  ',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ElevatedButton(
                // TODO: Let them choose am pm
                onPressed: () => context
                    .read<SchedulerBloc>()
                    .add(GenerateSchedule(isAm: false)),
                child: const Icon(Icons.refresh),
              ),
            ],
          ),
          reports.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'No Created Sessions! Click the Refresh Icon to generate!',
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final ReportLink report = reports[index];
                    return ReportTile(report: report);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildSessions() {
    final List<TimeSession> sessions = context.read<SchedulerBloc>().sessions;
    return _buildCardWidget(
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sessions  ',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => const CreateSessionDialog(),
                ),
                child: const Icon(Icons.add),
              ),
            ],
          ),
          sessions.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('No Created Sessions!'),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final TimeSession session = sessions[index];
                    return SessionTile(
                      session: session,
                      index: index,
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildCardWidget(Widget child) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.5),
                spreadRadius: 2,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Padding(padding: const EdgeInsets.all(8.0), child: child),
        ),
      ),
    );
  }
}
