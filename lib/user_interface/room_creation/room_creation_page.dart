import 'package:adams_county_scheduler/logical_interface/bloc/school_detail/school_detail_bloc.dart';
import 'package:adams_county_scheduler/user_interface/widgets/colored_container.dart';
import 'package:adams_county_scheduler/user_interface/widgets/input_field.dart';
import 'package:adams_county_scheduler/utilities/colors/ac_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RoomCreationPageArgs {
  final String schoolId;

  RoomCreationPageArgs({required this.schoolId});
}

class RoomCreationPage extends StatefulWidget {
  final String schoolId;

  const RoomCreationPage({super.key, required this.schoolId});

  @override
  State<RoomCreationPage> createState() => _RoomCreationPageState();
}

class _RoomCreationPageState extends State<RoomCreationPage> {
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _minSizeController = TextEditingController();
  final TextEditingController _maxSizeController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SchoolDetailBloc, SchoolDetailState>(
      listener: (context, state) {
        if (state is SchoolRoomsAdded) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add a Room'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InputField(
                  hintText: 'Room 102, Auditorium, gym, etc.',
                  controller: _nameController,
                  label: 'Room Name',
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Name may not be empty';
                    }

                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InputField(
                  hintText: 'Main Building, Annex, etc.',
                  controller: _buildingController,
                  label: 'Building Name',
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Building may not be empty';
                    }

                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InputField(
                  hintText: '0, 10, 15, etc.',
                  controller: _minSizeController,
                  label: 'Minimum Class Size',
                  validator: (value) {
                    final int max =
                        int.tryParse(_maxSizeController.text.trim()) ?? 0;
                    final int min =
                        int.tryParse(_minSizeController.text.trim()) ?? 0;
                    if (min > max) {
                      return 'Minimum class size cannot be greater than Maximum';
                    }

                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InputField(
                  hintText: '24, 50, 100, etc.',
                  controller: _maxSizeController,
                  label: 'Maximum Class Size',
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Maximum may not be empty';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: ColoredContainer(
                    onTap: () {
                      context.read<SchoolDetailBloc>().add(
                            AddRoom(
                              schoolId: widget.schoolId,
                              maxSize:
                                  int.parse(_maxSizeController.text.trim()),
                              building: _buildingController.text.trim(),
                              minSize:
                                  int.tryParse(_minSizeController.text.trim()),
                              name: _nameController.text.trim(),
                            ),
                          );
                    },
                    backgroundColor: ACColors.secondaryColor,
                    child: Text(
                      'Create Room',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
