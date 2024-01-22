import 'package:adams_county_scheduler/logical_interface/bloc/scheduler/scheduler_bloc.dart';
import 'package:adams_county_scheduler/objects/time_session.dart';
import 'package:adams_county_scheduler/utilities/functions/format_timestamp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../network_interface/api_clients/scheduler_api_client.dart';

class SessionTile extends StatelessWidget {
  final TimeSession session;
  final int index;

  const SessionTile({required this.session, required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.schedule),
      title:
          Text('${formatTimestamp(session.time)} (${session.session} Session)'),
      trailing: IconButton(
        onPressed: () async {
          await SchedulerApiClient().deleteSession(session.id);
          context.read<SchedulerBloc>().add(RemoveSession(index: index));
        },
        icon: const Icon(Icons.delete),
        color: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
