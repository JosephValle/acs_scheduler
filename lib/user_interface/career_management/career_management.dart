import 'package:adams_county_scheduler/user_interface/career_management/widgets/manage_career_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logical_interface/bloc/careers/careers_bloc.dart';

class CareerManagementArgs {
  final String schoolName;
  final String schoolId;

  CareerManagementArgs({required this.schoolId, required this.schoolName});
}

class CareerManagement extends StatelessWidget {
  final String schoolName;
  final String schoolId;

  const CareerManagement(
      {super.key, required this.schoolId, required this.schoolName,});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CareersBloc, CareersState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Manage $schoolName careers'),
          ),
          body: ListView.builder(shrinkWrap: true,
            itemCount: state.careers.length,
            itemBuilder: (context, index) => ManageCareerTile(
              schoolId: schoolId,
              career: state.careers.elementAt(index),
            ),
          ),
        );
      },
    );
  }
}
