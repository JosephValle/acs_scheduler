import 'package:adams_county_scheduler/logical_interface/bloc/schools/schools_bloc.dart';
import 'package:adams_county_scheduler/objects/school.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SchoolSelector extends StatefulWidget {
  final Function(School?) onChanged;
  final School initialSelection;

  const SchoolSelector({
    super.key,
    required this.onChanged,
    required this.initialSelection,
  });

  @override
  State<SchoolSelector> createState() => _SchoolSelectorState();
}

class _SchoolSelectorState extends State<SchoolSelector> {
  late List<School> schools;

  late String selection;

  @override
  void initState() {
    schools = context.read<SchoolsBloc>().schools;

    selection = widget.initialSelection.id;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      isExpanded: true,
        value: selection,
        items: schools
            .map<DropdownMenuItem<String>>(
              (e) => DropdownMenuItem(
                value: e.id,
                child: Text(e.shortName),
              ),
            )
            .toList(),
        onChanged: (value){
          if(value != null){
            widget.onChanged(schools.firstWhere((element) => element.id == value));
            setState(() {
              selection = value;
            });
          }
        },);
  }
}
