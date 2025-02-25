import 'package:adams_county_scheduler/user_interface/schools/widgets/school_tile.dart';
import 'package:adams_county_scheduler/utilities/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logical_interface/bloc/schools/schools_bloc.dart';

class SchoolsPage extends StatelessWidget {
  const SchoolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SchoolsBloc, SchoolsState>(
      builder: (context, state) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).pushNamed(Routes.schoolCreationPage);
            },
            child: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          body: ListView.builder(
            itemCount: state.schools.length,
            itemBuilder: (context, index) => SchoolTile(
              school: state.schools.elementAt(index),
            ),
          ),
        );
      },
    );
  }
}
