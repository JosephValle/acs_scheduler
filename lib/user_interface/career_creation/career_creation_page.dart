import 'package:adams_county_scheduler/logical_interface/bloc/careers/careers_bloc.dart';
import 'package:adams_county_scheduler/user_interface/widgets/colored_container.dart';
import 'package:adams_county_scheduler/user_interface/widgets/input_field.dart';
import 'package:adams_county_scheduler/utilities/colors/ac_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CareerCreationPage extends StatefulWidget {
  const CareerCreationPage({super.key});

  @override
  State<CareerCreationPage> createState() => _CareerCreationPageState();
}

class _CareerCreationPageState extends State<CareerCreationPage> {
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _excelNumController = TextEditingController();
  final TextEditingController _minClassSizeController = TextEditingController();
  final TextEditingController _maxClassSizeController = TextEditingController();
  bool popped = false;
  List<String> speakers = [];

  @override
  void initState() {
    popped = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CareersBloc, CareersState>(
      listener: (context, state) {
        if (state is CareerCreated) {
          popped = true;
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add a career'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    InputField(
                      hintText: 'Minimum Class Size',
                      controller: _minClassSizeController,
                      label: 'Min Class Size',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.parse(value) < 0) {
                          return 'Minimum class size must be 0 or greater';
                        }
                        return null;
                      },
                    ),
                    InputField(
                      hintText: 'Maximum Class Size',
                      controller: _maxClassSizeController,
                      label: 'Max Class Size',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        int? minSize =
                            int.tryParse(_minClassSizeController.text.trim());
                        int? maxSize = int.tryParse(value ?? '');
                        if (value == null ||
                            value.isEmpty ||
                            maxSize == null ||
                            minSize == null ||
                            maxSize < minSize) {
                          return 'Maximum class size must be greater than or equal to minimum class size';
                        }
                        return null;
                      },
                    ),
                    InputField(
                      hintText: 'Enter Excel Number',
                      controller: _excelNumController,
                      label: 'Excel Number',
                      keyboardType: TextInputType.number,
                      // Ensure numeric keyboard
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    InputField(
                      hintText: 'Adams County Land Surveyor',
                      controller: _nameController,
                      label: 'Career Name',
                      validator: (value) {
                        if (value?.trim().isEmpty ?? true) {
                          return 'Career name may not be empty';
                        }

                        return null;
                      },
                    ),
                    InputField(
                      hintText: 'Enter Room Details',
                      controller: _roomController,
                      label: 'Room',
                      validator: (value) {
                        if (value?.trim().isEmpty ?? true) {
                          return 'Room details may not be empty';
                        }
                        return null;
                      },
                    ),
                    InputField(
                      hintText: 'Business, Tech, etc.',
                      controller: _categoryController,
                      label: 'Career Category',
                      validator: (value) {
                        if (value?.trim().isEmpty ?? true) {
                          return 'Category may not be empty';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Presenters',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: speakers.length + 1,
                itemBuilder: (context, index) {
                  if (index == speakers.length) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InputField(
                        hintText: 'John Smith',
                        controller: TextEditingController(),
                        onSubmitted: (value) {
                          if (value != null &&
                              !speakers.any((element) => element == value)) {
                            setState(() {
                              speakers.add(value);
                            });
                          }
                          return null;
                        },
                      ),
                    );
                  } else {
                    return ListTile(
                      key: Key('${speakers.elementAt(index)}_$index'),
                      title: Text(
                        speakers.elementAt(index),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          if (speakers.any(
                            (element) => element == speakers.elementAt(index),
                          )) {
                            setState(() {
                              speakers.removeWhere(
                                (element) =>
                                    element == speakers.elementAt(index),
                              );
                            });
                          }
                        },
                      ),
                    );
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: ColoredContainer(
                    onTap: () {
                      int? excelNum =
                          int.tryParse(_excelNumController.text.trim());
                      int? minClassSize =
                          int.tryParse(_minClassSizeController.text.trim());
                      int? maxClassSize =
                          int.tryParse(_maxClassSizeController.text.trim());

                      if (excelNum != null &&
                          minClassSize != null &&
                          maxClassSize != null &&
                          maxClassSize >= minClassSize) {
                        context.read<CareersBloc>().add(
                              CreateCareer(
                                name: _nameController.text.trim(),
                                category: _categoryController.text.trim(),
                                speakers: speakers,
                                excelNum: excelNum,
                                room: _roomController.text.trim(),
                                maxClassSize: maxClassSize,
                                minClassSize: minClassSize,
                              ),
                            );
                      }
                    },
                    backgroundColor: ACColors.secondaryColor,
                    child: Text(
                      'Create Career',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
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
