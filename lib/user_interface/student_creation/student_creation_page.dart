import 'package:adams_county_scheduler/logical_interface/bloc/school_detail/school_detail_bloc.dart';
import 'package:adams_county_scheduler/logical_interface/bloc/schools/schools_bloc.dart';
import 'package:adams_county_scheduler/logical_interface/bloc/students/students_bloc.dart';
import 'package:adams_county_scheduler/objects/career_priority.dart';
import 'package:adams_county_scheduler/objects/school.dart';
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

  final List<TextEditingController> controllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  late School school;

  @override
  void initState() {
    school = context.read<SchoolsBloc>().schools.first;
    Student? student = widget.student;
    if (student != null) {
      _firstNameController.text = student.firstName;
      _lastNameController.text = student.lastName;
      _firstNameController.text = student.firstName;
      priority = student.careerPriority;
      controllers[0].text = student.careerPriority.firstChoice.toString();
      controllers[1].text = student.careerPriority.secondChoice.toString();
      controllers[2].text = student.careerPriority.thirdChoice.toString();
      controllers[3].text = student.careerPriority.fourthChoice.toString();
      controllers[4].text = student.careerPriority.fifthChoice.toString();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StudentsBloc, StudentsState>(
      listener: (context, state) {
        if (state is StudentCreated) {
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
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InputField(
                      onChanged: (value) {
                        setState(() {
                          priority = CareerPriority(
                            firstChoice: int.parse(controllers[0].text.trim()),
                            secondChoice: int.parse(controllers[1].text.trim()),
                            thirdChoice: int.parse(controllers[2].text.trim()),
                            fourthChoice: int.parse(controllers[3].text.trim()),
                            fifthChoice: int.parse(controllers[4].text.trim()),
                          );
                        });
                      },
                      hintText: '1, 2, 3, 4',
                      controller: controllers[index],
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: ColoredContainer(
                    onTap: () {
                      context.read<StudentsBloc>().add(
                            EditStudent(
                              id: widget.student!.id,
                              priority: priority,
                              firstName: _firstNameController.text.trim(),
                              lastName: _lastNameController.text.trim(),
                              schoolName: widget.student!.school,
                              grade:
                                  int.tryParse(_gradeController.text.trim()) ??
                                      -1,
                              schoolId: widget.student!.schoolId,
                            ),
                          );
                    },
                    backgroundColor: ACColors.secondaryColor,
                    child: Text(
                      '${widget.student != null ? 'Edit' : 'Create'} Student',
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
