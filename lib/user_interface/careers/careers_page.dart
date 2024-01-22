import 'package:adams_county_scheduler/user_interface/careers/widgets/career_tile.dart';
import 'package:adams_county_scheduler/utilities/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logical_interface/bloc/careers/careers_bloc.dart';

class CareersPage extends StatelessWidget {
  const CareersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CareersBloc, CareersState>(
      builder: (context, state) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).pushNamed(Routes.careerCreationPage);
            },
            child: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          body: Column(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Careers',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: state.careers.length,
                  itemBuilder: (context, index) => CareerTile(
                    career: state.careers.elementAt(index),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
