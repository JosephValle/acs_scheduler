import 'package:adams_county_scheduler/logical_interface/bloc/scheduler/scheduler_bloc.dart';
import 'package:adams_county_scheduler/objects/time_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../network_interface/api_clients/scheduler_api_client.dart';

class CreateSessionDialog extends StatefulWidget {
  const CreateSessionDialog({super.key});

  @override
  State<CreateSessionDialog> createState() => _CreateSessionDialogState();
}

class _CreateSessionDialogState extends State<CreateSessionDialog> {
  String _selectedSession = 'AM';
  TimeOfDay? _selectedTime;
  static final DateTime _fixedDate = DateTime(2000, 1, 1);

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTitle(context),
            _buildSessionSelector(),
            _buildTimeSelector(context),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Create Session',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _buildSessionSelector() {
    return Row(
      children: [
        const Text('Session:'),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _sessionButton('AM'),
              _sessionButton('PM'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sessionButton(String session) {
    return TextButton(
      onPressed: () => setState(() {
        _selectedSession = session;
      }),
      child: Text(
        session,
        style: _selectedSession == session
            ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)
            : null,
      ),
    );
  }

  Widget _buildTimeSelector(BuildContext context) {
    return ListTile(
      title: const Text('Selected Time:'),
      subtitle: Text(
        _selectedTime != null
            ? _selectedTime!.format(context)
            : 'Click to Select!',
      ),
      onTap: () => _selectTime(context),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => _handleCreate(context),
          child: const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _handleCreate(BuildContext context) async {
    if (_selectedTime == null) {
      return;
    }
    final DateTime time = DateTime(
      _fixedDate.year,
      _fixedDate.month,
      _fixedDate.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    // TODO: Move to BLOC
    final TimeSession session = await SchedulerApiClient().createSession(
      time: time,
      session: _selectedSession,
    );
    context.read<SchedulerBloc>().add(AddSession(session: session));
    Navigator.pop(context);
  }
}
