import 'package:adams_county_scheduler/logical_interface/bloc/school_detail/school_detail_bloc.dart';
import 'package:adams_county_scheduler/logical_interface/bloc/schools/schools_bloc.dart';
import 'package:adams_county_scheduler/logical_interface/bloc/students/students_bloc.dart';
import 'package:adams_county_scheduler/objects/career_priority.dart';
import 'package:adams_county_scheduler/objects/school.dart';
import 'package:adams_county_scheduler/user_interface/student_creation/widgets/career_prority_builder.dart';
import 'package:adams_county_scheduler/user_interface/student_creation/widgets/school_selector.dart';
import 'package:adams_county_scheduler/user_interface/widgets/colored_container.dart';
import 'package:adams_county_scheduler/user_interface/widgets/input_field.dart';
import 'package:adams_county_scheduler/utilities/colors/ac_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../objects/student.dart';

class StudentCreationPage extends StatefulWidget {
  final Student? student;

  const StudentCreationPage({this.student, super.key});

  @override
  State<StudentCreationPage> createState() => _StudentCreationPageState();
}

class _StudentCreationPageState extends State<StudentCreationPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();

  CareerPriority priority = CareerPriority(
    fifthChoice: -1,
    firstChoice: -1,
    fourthChoice: -1,
    secondChoice: -1,
    thirdChoice: -1,
  );

  late School school;

  @override
  void initState() {
    school = context.read<SchoolsBloc>().schools.first;
    Student? student = widget.student;
    if (student !=null) {
      _firstNameController.text = student.firstName;
      _lastNameController.text = student.lastName;
      _firstNameController.text = student.firstName;
      priority = student.careerPriority;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StudentsBloc, StudentsState>(
      listener: (context, state) {
        if (state is StudentCreated) {
          context.read<SchoolDetailBloc>().add(
                AddStudent(
                  student: state.student,
                  schoolId: state.student.schoolId,
                ),
              );
          Navigator.of(context).pop();

        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Update a Student'),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputField(
                hintText: 'Jane',
                controller: _firstNameController,
                label: 'First Name',
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'First Name may not be empty';
                  }

                  return null;
                },
              ),
              InputField(
                hintText: 'Doe',
                controller: _lastNameController,
                label: 'Last Name',
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Last Name may not be empty';
                  }

                  return null;
                },
              ),
              InputField(
                hintText: '12',
                controller: _gradeController,
                maxCharacters: 2,
                label: 'Grade (Optional)',
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Student's School'",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SchoolSelector(
                  onChanged: (newSchool) {
                    if (newSchool != null && school != newSchool) {
                      setState(() {
                        school = newSchool;
                      });
                    }
                  },
                  initialSelection: school,
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Student's Preferences (Must match a career name exactly)",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              CareerPriorityBuilder(
                onChanged: (newPriority) {
                  setState(() {
                    priority = newPriority;
                  });
                }, careerPriority: priority,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: ColoredContainer(
                    onTap: () {
                      context.read<StudentsBloc>().add(
                            CreateStudent(
                              priority: priority,
                              firstName: _firstNameController.text.trim(),
                              lastName: _lastNameController.text.trim(),
                              schoolName: school.shortName,
                              grade:
                                  int.tryParse(_gradeController.text.trim()) ??
                                      -1,
                              schoolId: school.id,
                            ),
                          );
                    },
                    backgroundColor: ACColors.secondaryColor,
                    child: Text(
                      'Create Student',
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
