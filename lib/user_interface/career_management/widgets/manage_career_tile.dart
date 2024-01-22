import 'package:adams_county_scheduler/logical_interface/bloc/careers/careers_bloc.dart';
import 'package:adams_county_scheduler/objects/career.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../objects/session.dart';

class ManageCareerTile extends StatefulWidget {
  final String schoolId;
  final Career career;

  const ManageCareerTile(
      {super.key, required this.schoolId, required this.career,});

  @override
  State<ManageCareerTile> createState() => _ManageCareerTileState();
}

class _ManageCareerTileState extends State<ManageCareerTile> {
  bool? added;

  late Session selectedSession;

  @override
  void initState() {
    context.read<CareersBloc>().add(
          CheckCareerExistsForSchool(
              careerId: widget.career.id, schoolId: widget.schoolId,),
        );

    selectedSession = widget.career.session;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CareersBloc, CareersState>(
      listenWhen: (oldState, newState) =>
          newState is CareerExistsResult &&
          newState.careerId == widget.career.id &&
          newState.schoolId == widget.schoolId,
      listener: (context, state) {
        if (state is CareerExistsResult) {
          setState(() {
            added = state.exists;
          });
        }
      },
      child: ListTile(
        leading: added == null
            ? const CircularProgressIndicator()
            : Checkbox(
                value: added!,
                onChanged: (value) {
                  if (value != null) {
                    if (value) {
                      context.read<CareersBloc>().add(
                            AddCareerToSchool(
                                schoolId: widget.schoolId,
                                career: widget.career,),
                          );
                    } else {
                      context.read<CareersBloc>().add(
                            RemoveCareerFromSchool(
                                schoolId: widget.schoolId,
                                careerId: widget.career.id,),
                          );
                    }

                    setState(() {
                      added = value;
                    });
                  }
                },),
        trailing: added ?? false
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: Session.values
                    .map((session) => Container(
                          constraints: BoxConstraints(
                              minWidth: MediaQuery.of(context).size.width * .05,
                              maxWidth: MediaQuery.of(context).size.width * .1,
                              maxHeight:
                                  MediaQuery.of(context).size.height * .15,
                              minHeight:
                                  MediaQuery.of(context).size.height * .1,),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Radio(
                                  value: session,
                                  groupValue: selectedSession,
                                  onChanged: (newSession) {
                                    if (newSession != null &&
                                        newSession != selectedSession) {
                                      setState(() {
                                        selectedSession = newSession;
                                      });
                                      context.read<CareersBloc>().add(
                                            SetCareerSessionForSchool(
                                                careerId: widget.career.id,
                                                schoolId: widget.schoolId,
                                                session: newSession,),
                                          );
                                    }
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    describeEnum(session),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),)
                    .toList(),
              )
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.career.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              widget.career.category,
              style: const TextStyle(fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
    );
  }
}
