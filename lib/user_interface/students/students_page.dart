import 'package:adams_county_scheduler/logical_interface/bloc/students/students_bloc.dart';
import 'package:adams_county_scheduler/logical_interface/cubit/student_sort/student_sort_cubit.dart';
import 'package:adams_county_scheduler/user_interface/student_creation/student_creation_page.dart';
import 'package:adams_county_scheduler/user_interface/students/widgets/clear_students_dialog.dart';
import 'package:adams_county_scheduler/user_interface/widgets/colored_container.dart';
import 'package:adams_county_scheduler/utilities/colors/ac_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utilities/routes/routes.dart';

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentsBloc, StudentsState>(
      builder: (context, state) {
        return Scaffold(
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height / 20,
                    minWidth: MediaQuery.of(context).size.width * .05,
                    maxWidth: MediaQuery.of(context).size.width * .1,
                  ),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: ColoredContainer(
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) => const ClearStudentsDialog(),
                      ),
                      backgroundColor: ACColors.secondaryColor,
                      child: const Text('Clear All'),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height / 20,
                    minWidth: MediaQuery.of(context).size.width * .05,
                    maxWidth: MediaQuery.of(context).size.width * .1,
                  ),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: ColoredContainer(
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(Routes.bulkStudentUploadPage);
                      },
                      backgroundColor: ACColors.secondaryColor,
                      child: const Text('Bulk Upload'),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: BlocBuilder<StudentSortCubit, StudentSortState>(
            builder: (context, sortState) {
              return Column(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Students',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: DataTable(
                        sortAscending: !sortState.ascending,
                        sortColumnIndex: sortState.index,
                        columnSpacing: MediaQuery.of(context).size.width * .025,
                        columns: [
                          DataColumn(
                            onSort: (index, ascending) {
                              context
                                  .read<StudentSortCubit>()
                                  .sortStudents(index, ascending);
                              context.read<StudentsBloc>().add(
                                    SortStudents(
                                      index: index,
                                      ascending: ascending,
                                    ),
                                  );
                            },
                            label: const Expanded(
                              child: Text('First Name'),
                            ),
                          ),
                          DataColumn(
                            onSort: (index, ascending) {
                              context
                                  .read<StudentSortCubit>()
                                  .sortStudents(index, ascending);
                              context.read<StudentsBloc>().add(
                                    SortStudents(
                                      index: index,
                                      ascending: ascending,
                                    ),
                                  );
                            },
                            label: const Expanded(
                              child: Text('Last Name'),
                            ),
                          ),
                          DataColumn(
                            onSort: (index, ascending) {
                              context
                                  .read<StudentSortCubit>()
                                  .sortStudents(index, ascending);
                              context.read<StudentsBloc>().add(
                                    SortStudents(
                                      index: index,
                                      ascending: ascending,
                                    ),
                                  );
                            },
                            label: const Expanded(
                              child: Text('School'),
                            ),
                          ),
                          DataColumn(
                            onSort: (index, ascending) {
                              context
                                  .read<StudentSortCubit>()
                                  .sortStudents(index, ascending);
                              context.read<StudentsBloc>().add(
                                    SortStudents(
                                      index: index,
                                      ascending: ascending,
                                    ),
                                  );
                            },
                            label: const Expanded(
                              child: Text('First Choice'),
                            ),
                          ),
                          DataColumn(
                            onSort: (index, ascending) {
                              context
                                  .read<StudentSortCubit>()
                                  .sortStudents(index, ascending);
                              context.read<StudentsBloc>().add(
                                    SortStudents(
                                      index: index,
                                      ascending: ascending,
                                    ),
                                  );
                            },
                            label: const Expanded(
                              child: Text('Second Choice'),
                            ),
                          ),
                          DataColumn(
                            onSort: (index, ascending) {
                              context
                                  .read<StudentSortCubit>()
                                  .sortStudents(index, ascending);
                              context.read<StudentsBloc>().add(
                                    SortStudents(
                                      index: index,
                                      ascending: ascending,
                                    ),
                                  );
                            },
                            label: const Expanded(
                              child: Text('Third Choice'),
                            ),
                          ),
                          DataColumn(
                            onSort: (index, ascending) =>
                                context.read<StudentsBloc>().add(
                                      SortStudents(
                                        index: index,
                                        ascending: ascending,
                                      ),
                                    ),
                            label: const Expanded(child: Text('Fourth Choice')),
                          ),
                          DataColumn(
                            onSort: (index, ascending) =>
                                context.read<StudentsBloc>().add(
                                      SortStudents(
                                        index: index,
                                        ascending: ascending,
                                      ),
                                    ),
                            label: const Expanded(child: Text('Fifth Choice')),
                          ),
                          const DataColumn(
                            label: Expanded(child: Text('Edit ')),
                          ),
                        ],
                        rows: state.students
                            .map<DataRow>(
                              (e) => DataRow(
                                cells: [
                                  DataCell(
                                    Text(e.firstName),
                                  ),
                                  DataCell(
                                    Text(e.lastName),
                                  ),
                                  DataCell(
                                    Text(e.school),
                                  ),
                                  DataCell(
                                    Text(
                                      e.careerPriority.firstChoice.toString(),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      e.careerPriority.secondChoice.toString(),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      e.careerPriority.thirdChoice.toString(),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      e.careerPriority.fourthChoice.toString(),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      e.careerPriority.fifthChoice.toString(),
                                    ),
                                  ),
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => {
                                        // TODO: Implement Student Editing
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                StudentCreationPage(
                                              student: e,
                                            ),
                                          ),
                                        ),
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
