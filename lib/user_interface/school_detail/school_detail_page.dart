import 'package:adams_county_scheduler/logical_interface/bloc/careers/careers_bloc.dart';
import 'package:adams_county_scheduler/logical_interface/bloc/school_detail/school_detail_bloc.dart';
import 'package:adams_county_scheduler/objects/school.dart';
import 'package:adams_county_scheduler/user_interface/school_detail/widgets/student_builder.dart';
import 'package:adams_county_scheduler/user_interface/schools/widgets/school_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class SchoolDetailPageArgs {
  final School school;

  SchoolDetailPageArgs({required this.school});
}

class SchoolDetailPage extends StatefulWidget {
  final School school;

  const SchoolDetailPage({super.key, required this.school});

  @override
  State<SchoolDetailPage> createState() => _SchoolDetailPageState();
}

class _SchoolDetailPageState extends State<SchoolDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController tabController;

  late final IndexedStack pages;

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    pages = IndexedStack(
      children: [
        Expanded(child: StudentBuilder(schoolId: widget.school.id)),
      ],
    );

    context
        .read<SchoolDetailBloc>()
        .add(LoadSchoolDetails(schoolId: widget.school.id));


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CareersBloc, CareersState>(
      listenWhen: (oldState, newState) =>
      (newState is CareerAddedToSchool &&
          newState.schoolId == widget.school.id) ||
          (newState is CareerRemovedFromSchool &&
              newState.schoolId == widget.school.id),
      listener: (context, state) {

        if (state is CareerRemovedFromSchool) {
          context.read<SchoolDetailBloc>().add(
            RemoveCareer(
              careerId: state.careerId,
              schoolId: state.schoolId,
            ),
          );
        } else if (state is CareerAddedToSchool) {
          context
              .read<SchoolDetailBloc>()
              .add(AddCareer(schoolId: state.schoolId, career: state.career));
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            SchoolTile(school: widget.school, header: true),
            TabBar(
              onTap: (index) {
                setState(() {});
              },
              controller: tabController,
              tabs: const [
                Tab(
                  text: 'Students',
                  icon: Icon(Icons.people_alt_outlined),
                ),
              ],
            ),
            pages.children.elementAt(tabController.index),
          ],
        ),
      ),
    );
  }
}
