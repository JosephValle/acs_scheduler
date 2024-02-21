import 'package:adams_county_scheduler/network_interface/api_clients/schools_api_client.dart';
import 'package:adams_county_scheduler/objects/school.dart';
import 'package:adams_county_scheduler/user_interface/school_detail/school_detail_page.dart';
import 'package:adams_county_scheduler/user_interface/widgets/colored_container.dart';
import 'package:adams_county_scheduler/utilities/colors/ac_colors.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../../utilities/routes/routes.dart';

class SchoolTile extends StatefulWidget {
  final School school;
  final bool header;

  const SchoolTile({super.key, required this.school, this.header = false});

  @override
  State<SchoolTile> createState() => _SchoolTileState();
}

class _SchoolTileState extends State<SchoolTile> {
  late School school;
  late bool header;

  @override
  void initState() {
    super.initState();
    header = widget.header;
    school = widget.school;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: header ? EdgeInsets.zero : const EdgeInsets.all(8.0),
      child: MouseRegion(
        cursor: header ? MouseCursor.defer : SystemMouseCursors.click,
        child: ColoredContainer(
          onTap: () => header
              ? null
              : Navigator.of(context).pushNamed(
                  Routes.schoolDetailPage,
                  arguments: SchoolDetailPageArgs(school: school),
                ),
          height: MediaQuery.of(context).size.height / 3,
          childPadding: EdgeInsets.zero,
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius:
                        header ? BorderRadius.zero : BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        school.imageUrl.isEmpty
                            ? Container(
                                width: double.infinity,
                                height: double.infinity,
                                color: ACColors.secondaryColor,
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                      school.imageUrl,
                                    ),
                                  ),
                                ),
                              ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: FractionalOffset.topCenter,
                              end: FractionalOffset.bottomCenter,
                              colors: [
                                Theme.of(context)
                                    .colorScheme
                                    .surface
                                    .withOpacity(0.0),
                                Theme.of(context)
                                    .colorScheme
                                    .background
                                    .withOpacity(.7),
                              ],
                              stops: const [
                                0.0,
                                .7,
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                                onPressed: () async {
                                  await SchoolsApiClient()
                                      .deleteSchoolStudents(school: school);
                                  setState(() {
                                    school = school.copyWith(studentCount: 0);
                                  });
                                },
                                icon: Icon(Icons.delete)),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: header
                                    ? Radius.zero
                                    : const Radius.circular(10),
                                bottomRight: const Radius.circular(10),
                              ),
                              color: Theme.of(context)
                                  .colorScheme
                                  .background
                                  .withOpacity(.7),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: AutoSizeText(
                                '${school.name} - ${school.time}',
                                maxLines: 2,
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width / 30,
                                ),
                              ),
                            ),
                          ),
                        ),
                        header
                            ? Container()
                            : Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: RichText(
                                            text: TextSpan(
                                              text: 'Total Students:\t',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w200,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onBackground,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: school.studentCount
                                                      .toString(),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ],
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
