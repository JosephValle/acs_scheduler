import 'package:adams_county_scheduler/logical_interface/bloc/school_detail/school_detail_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentBuilder extends StatelessWidget {
  final String schoolId;

  const StudentBuilder({super.key, required this.schoolId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SchoolDetailBloc, SchoolDetailState>(
      buildWhen: (oldState, newState) {
        if (newState.schoolId == schoolId) {
          if (newState is SchoolInformationLoading ||
              newState is SchoolInformationLoaded ||
              newState is SchoolStudentsAdded) {
            return true;
          }
        }
        return false;
      },
      builder: (context, state) {
        return ListView.builder(
          itemCount: state.students.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(
              '${state.students.elementAt(index).lastName}, ${state.students.elementAt(index).firstName}',
            ),
          ),
        );
      },
    );
  }
}
