import 'package:adams_county_scheduler/user_interface/careers/widgets/delete_career_dialog.dart';
import 'package:flutter/material.dart';

import '../../../objects/career.dart';

class CareerTile extends StatelessWidget {
  final Career career;

  const CareerTile({required this.career, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          color: Colors.grey,
          height: 0.5,
        ),
        ListTile(
          leading: const Icon(Icons.work),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                career.name,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Text('Room: ${career.room} | Id: ${career.excelNum}'),
              Text('Min: ${career.minClassSize} | Max: ${career.maxClassSize}'),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _handleDelete(context),
          ),
        ),
        Container(
          width: double.infinity,
          color: Colors.grey,
          height: 0.5,
        ),
      ],
    );
  }

  void _handleDelete(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => DeleteCareerDialog(career: career),);
  }
}
