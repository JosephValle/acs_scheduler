import 'package:adams_county_scheduler/logical_interface/bloc/careers/careers_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../objects/career.dart';

class DeleteCareerDialog extends StatelessWidget {
  final Career career;

  const DeleteCareerDialog({required this.career, super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(8.0),
      content: SizedBox(
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Are you sure you want to delete ${career.name}?',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'This cannot be undone',
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),),
                    TextButton(
                        onPressed: () => _handleDelete(context),
                        child: const Text('DELETE'),),
                  ],
                ),
              ),
            ],
          ),),
    );
  }

  void _handleDelete(BuildContext context) {
    context.read<CareersBloc>().add(DeleteCareer(career: career));
    Navigator.pop(context);
  }
}
