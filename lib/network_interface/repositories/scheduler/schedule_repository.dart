import 'package:adams_county_scheduler/network_interface/api_clients/careers_api_client.dart';
import 'package:adams_county_scheduler/network_interface/api_clients/students_api_client.dart';
import 'package:adams_county_scheduler/network_interface/repositories/scheduler/base_schedule_repository.dart';
import 'package:adams_county_scheduler/objects/class_session.dart';
import 'package:adams_county_scheduler/objects/export_careers_schedule.dart';
import 'package:adams_county_scheduler/objects/export_student_schedule.dart';
import 'package:adams_county_scheduler/objects/student_schedule.dart';
import 'package:adams_county_scheduler/utilities/functions/format_timestamp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';
import '../../../objects/career.dart';
import '../../../objects/school.dart';
import '../../../objects/student.dart';
import '../../../objects/time_session.dart';
import '../../api_clients/scheduler_api_client.dart';
import '../../api_clients/schools_api_client.dart';

class ScheduleRepository extends BaseScheduleRepository {
  final SchedulerApiClient _schedulerApiClient = SchedulerApiClient();
  final Uuid _uuid = const Uuid();
  final Stopwatch stopwatch = Stopwatch();
  List<ClassSession> classes = [];
  List<StudentSchedule> studentSchedules = [];

  @override
  Future<void> generateSchedule(bool isAm) async {
    classes = [];
    studentSchedules = [];
    debugPrint('Start');
    stopwatch.reset();
    stopwatch.start();
    final String time = isAm ? 'AM' : 'PM';
    print('TIME: $time');
    final List<Career> careers = await _getAllCareers();
    debugPrint(
      'Done downloading careers: ${stopwatch.elapsedMilliseconds} ms in',
    );
    final List<School> schools = await _getAllSchools();

    // Student objects have a field 'school' that corresponds to a school shortName
// Create a map of school shortName to School object for efficient lookup
    final Map<String, School> schoolMap = {
      for (var school in schools) school.shortName: school,
    };
    print(schoolMap);
    final List<Student> unfiltered = await _getAllStudents();
    final List<Student> students = unfiltered.where((student) {
      // Use the student's school field to get the corresponding School object from the map
      final School? studentSchool = schoolMap[student.school];
      if (studentSchool?.time == time) {
        print('Student: ${student.lastName}, School: ${student.school}');
      }
      return studentSchool?.time == time;
    }).toList();
    debugPrint(
      'Done downloading students: ${stopwatch.elapsedMilliseconds} ms in',
    );

    final List<TimeSession> sessions = (await _getAllSessions(isAm))
        .where((element) => element.session.contains(time))
        .toList();
    debugPrint(
      'Done downloading sessions: ${stopwatch.elapsedMilliseconds} ms in',
    );

    debugPrint(
      'Total Students: ${students.length}, expected classes: ${students.length * sessions.length}',
    );_generateClasses(careers: careers, sessions: sessions, students: students);
    _initialAssignment(
      students: students,
      careers: careers,
      sessions: sessions,
    );

    // Consolidate classes after initial assignment
    _consolidateClasses(careers: careers, sessions: sessions);

    // Handle under-enrolled classes
    _handleUnderEnrolledClasses(careers: careers, sessions: sessions);

    // Balance overcrowded classes
    _balanceOvercrowdedClasses(careers: careers, sessions: sessions);

    // Secondary assignment for unfilled schedules
    _secondaryAssignment(careers: careers);

    // Final assignment to ensure full schedules
    _finalAssignment();

    // Final cleanup and sorting
    _finalCleanUp();
    debugPrint('Done All Scheduling: ${stopwatch.elapsedMilliseconds} ms in');

    await _createInFirebase(
      careers: careers,
      timeSessions: sessions,
      time: time,
    );
  }

  Future<void> _createInFirebase({
    required List<Career> careers,
    required List<TimeSession> timeSessions,
    required String time,
  }) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      List<ExportStudentSchedule> exportStudentSchedule = [];
      for (StudentSchedule schedule in studentSchedules) {
        List<ExportStudentSession> exportStudentSessions = [];
        for (ClassSession session in schedule.sessions) {
          exportStudentSessions.add(
            ExportStudentSession(
              time: formatTimestamp(session.timeSession.time),
              roomName: session.career.room,
              careerName: session.career.name,
            ),
          );
        }
        exportStudentSchedule.add(
          ExportStudentSchedule(
            formattedName:
                '${schedule.student.lastName}, ${schedule.student.firstName}',
            school: schedule.student.school,
            sessions: exportStudentSessions,
          ),
        );
      }
      debugPrint(
        'Done Creating Student export objects: ${stopwatch.elapsedMilliseconds} ms in',
      );

      // Create CareerCountsTable

      List<ExportCareerSchedule> exportCareerSchedule = [];
      for (Career career in careers) {
        List<ClassSession> sessions =
            classes.where((element) => element.career.id == career.id).toList();
        List<int> counts = [0, 0, 0];
        List<List<Student>> students = [[], [], []];
        sessions
            .sort((a, b) => a.timeSession.time.compareTo(b.timeSession.time));
        for (int i = 0; i < timeSessions.length; i += 1) {
          final TimeSession timeSession = timeSessions[i];
          for (int j = 0; j < sessions.length; j++) {
            final ClassSession classSession = sessions[j];
            if (timeSession.time == classSession.timeSession.time) {
              counts[i] = classSession.students.length;
              students[i].addAll(classSession.students);
            }
          }
        }
        exportCareerSchedule.add(
          ExportCareerSchedule(
            excelId: career.excelNum,
            career: career.name,
            room: career.room,
            sessionCounts: counts,
            students: students,
          ),
        );
      }
      debugPrint(
        'Done Creating Career export objects: ${stopwatch.elapsedMilliseconds} ms in',
      );

      List<Map<String, dynamic>> studentExport = [];
      for (ExportStudentSchedule student in exportStudentSchedule) {
        studentExport.add(student.toJson());
      }
      debugPrint(
        'Done Creating Student export json: ${stopwatch.elapsedMilliseconds} ms in',
      );

      List<Map<String, dynamic>> careerExport = [];
      for (ExportCareerSchedule career in exportCareerSchedule) {
        careerExport.add(career.toJson());
      }
      debugPrint(
        'Done Creating Career export json: ${stopwatch.elapsedMilliseconds} ms in',
      );

      await _deleteCollection(firestore.collection('studentExport'));

      await _deleteCollection(firestore.collection('careerExport'));
      debugPrint(
        'Done Deleting old generation: ${stopwatch.elapsedMilliseconds} ms in',
      );
      await _batchUpload(firestore.collection('studentExport'), studentExport);
      debugPrint('Student Batch Done: ${stopwatch.elapsedMilliseconds} ms in');
      await _batchUpload(firestore.collection('careerExport'), careerExport);
      debugPrint('Career Batch Done: ${stopwatch.elapsedMilliseconds} ms in');
      debugPrint('Done Firebase: ${stopwatch.elapsedMilliseconds} ms in');
      stopwatch.stop();

      await _schedulerApiClient.createMasterList(
        schedules: exportStudentSchedule,
        time: time,
      );
      await _schedulerApiClient.createStudentSchedule(
        schedules: exportStudentSchedule,
        time: time,
      );
      await _schedulerApiClient.createAttendanceSchedule(
        careerSessions: exportCareerSchedule,
        times: timeSessions,
        time: time,
      );
      await _schedulerApiClient.createCareerCounts(
        careers: exportCareerSchedule,
        time: time,
      );
    } catch (e) {
      debugPrint('Error with firebase: $e');
      if (e is Error) {
        debugPrint(e.stackTrace.toString());
      }
    }
  }

  Future<List<School>> _getAllSchools() async =>
      await SchoolsApiClient().loadSchools();

  Future<void> _deleteCollection(CollectionReference collection) async {
    const int batchSize = 500;
    QuerySnapshot snapshot;
    do {
      snapshot = await collection.limit(batchSize).get();
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (DocumentSnapshot ds in snapshot.docs) {
        batch.delete(ds.reference);
      }
      await batch.commit();
    } while (snapshot.docs.isNotEmpty);
  }

  Future<void> _batchUpload(
    CollectionReference collection,
    List<Map<String, dynamic>> data,
  ) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (var item in data) {
      DocumentReference docRef = collection.doc();
      batch.set(docRef, item);
    }
    await batch.commit();
  }

  void _finalCleanUp() {
    studentSchedules.sort((a, b) {
      int schoolCompare = a.student.school.compareTo(b.student.school);
      if (schoolCompare != 0) return schoolCompare;

      int lastNameCompare = a.student.lastName.compareTo(b.student.lastName);
      if (lastNameCompare != 0) return lastNameCompare;

      return a.student.firstName.compareTo(b.student.firstName);
    });
  }

  void _finalAssignment() {
    List<StudentSchedule> remainingSchedules =
        studentSchedules.where((element) => !element.isFull).toList();

    for (StudentSchedule schedule in remainingSchedules) {
      List<ClassSession> availableClasses = classes
          .where(
            (cs) =>
                !cs.isFull &&
                getSessionAvailable(correspondingClass: cs, schedule: schedule),
          )
          .toList();

      // Sort available classes by the fewest number of students to balance class sizes
      availableClasses
          .sort((a, b) => a.students.length.compareTo(b.students.length));

      for (ClassSession cs in availableClasses) {
        cs.students.add(schedule.student);
        schedule.sessions.add(cs);

        if (schedule.isFull) break;
      }
    }
  }

  void _secondaryAssignment({
    required List<Career> careers,
  }) {
    // Iterate over each student schedule that isn't full
    List<StudentSchedule> partiallyFilledSchedules =
        studentSchedules.where((schedule) => !schedule.isFull).toList();
    for (StudentSchedule schedule in partiallyFilledSchedules) {
      // Revisit each student's career priorities for remaining open slots
      for (int priority = 0; priority < 5; priority++) {
        int careerId = getCareerId(index: priority, student: schedule.student);
        Career? priorityCareer =
            careers.firstWhereOrNull((career) => career.excelNum == careerId);

        if (priorityCareer == null) {
          continue;
        }

        List<ClassSession> availableClasses = classes
            .where(
              (session) =>
                  session.career.id == priorityCareer.id &&
                  !session.isFull &&
                  getSessionAvailable(
                    correspondingClass: session,
                    schedule: schedule,
                  ),
            )
            .toList();

        for (ClassSession classSession in availableClasses) {
          if (!classSession.isFull &&
              getSessionAvailable(
                correspondingClass: classSession,
                schedule: schedule,
              )) {
            classSession.students.add(schedule.student);
            schedule.sessions.add(classSession);
            break;
          }
        }
        if (schedule.isFull) break;
      }
    }
  }

  // void _cleanup() {
  //   classes.removeWhere((element) => element.students.isEmpty);
  //   classes.sort((a, b) => a.students.length.compareTo(b.students.length));
  // }
  void _generateClasses({
    required List<Career> careers,
    required List<TimeSession> sessions,
    required List<Student> students,
  }) {
    Map<String, int> careerDemand = {};

    // Calculate demand for each career based on student preferences
    for (Student student in students) {
      for (int i = 0; i < 5; i++) {
        int careerId = getCareerId(index: i, student: student);
        careerDemand[careerId.toString()] =
            (careerDemand[careerId.toString()] ?? 0) + 1;
      }
    }

    for (Career career in careers) {
      int demand = careerDemand[career.excelNum.toString()] ?? 0;

      // Calculate the maximum number of classes that can meet minClassSize
      int maxClassesBasedOnMinSize = (demand / career.minClassSize).floor();
      int numberOfClasses = maxClassesBasedOnMinSize > 0
          ? maxClassesBasedOnMinSize
          : 1; // Ensure at least one class is created if there's any demand

      for (TimeSession session in sessions) {
        for (int i = 0; i < numberOfClasses; i++) {
          classes.add(
            ClassSession(
              timeSession: session,
              career: career,
              students: [],
              uniqueId: _uuid.v4(),
            ),
          );
        }
      }
    }
  }

  void _initialAssignment({
    required List<Student> students,
    required List<Career> careers,
    required List<TimeSession> sessions,
  }) {
    // Identify the placeholder career
    int placeholderCareerExcelNum = 86; // Replace with actual excelNum
    Career? placeholderCareer = careers.firstWhereOrNull(
      (career) => career.excelNum == placeholderCareerExcelNum,
    );

    // Identify the first session
    TimeSession? firstSession = sessions.isNotEmpty ? sessions.first : null;

    for (Student student in students) {
      StudentSchedule schedule = StudentSchedule(
        uniqueId: _uuid.v4(),
        sessionCount: sessions.length,
        student: student,
        sessions: [],
      );

      if (student.school == 'NOHS' &&
          placeholderCareer != null &&
          firstSession != null) {
        // Assign NOHS students to the placeholder class in the first session
        ClassSession? placeholderClass = classes.firstWhereOrNull(
          (cs) =>
              cs.career.id == placeholderCareer.id &&
              cs.timeSession.time == firstSession.time,
        );

        if (placeholderClass != null && !placeholderClass.isFull) {
          placeholderClass.students.add(student);
          schedule.sessions.add(placeholderClass);
        }
      }

      // Proceed with other sessions
      for (int i = 0; i < 5; i++) {
        final int careerPriority = getCareerId(index: i, student: student);
        final Career? career = careers.firstWhereOrNull(
          (element) => element.excelNum == careerPriority,
        );

        if (career == null) {
          continue;
        }

        // Skip the placeholder career for NOHS students since it's already assigned
        if (student.school == 'NOHS' && career.id == placeholderCareer?.id) {
          continue;
        }

        // Get available classes for this career, sorted by enrollment
        final List<ClassSession> correspondingClasses = classes
            .where(
              (element) =>
                  element.career.id == career.id &&
                  !element.isFull &&
                  getSessionAvailable(
                      correspondingClass: element, schedule: schedule,),
            )
            .toList()
          ..sort((a, b) => a.students.length.compareTo(b.students.length));

        for (ClassSession correspondingClass in correspondingClasses) {
          if (getSessionAvailable(
              correspondingClass: correspondingClass, schedule: schedule,)) {
            correspondingClass.students.add(student);
            schedule.sessions.add(correspondingClass);
            break;
          }
        }

        if (schedule.isFull) {
          break;
        }
      }

      studentSchedules.add(schedule);
    }
  }

  int getCareerId({required int index, required Student student}) {
    if (index == 0) {
      return student.careerPriority.firstChoice;
    } else if (index == 1) {
      return student.careerPriority.secondChoice;
    } else if (index == 2) {
      return student.careerPriority.thirdChoice;
    } else if (index == 3) {
      return student.careerPriority.fourthChoice;
    } else if (index == 4) {
      return student.careerPriority.fifthChoice;
    } else {
      return -1;
    }
  }

  Future<List<Career>> _getAllCareers() async =>
      await CareersApiClient().loadCareers();

  Future<List<Student>> _getAllStudents() async =>
      await StudentApiClient().getStudents();

  Future<List<TimeSession>> _getAllSessions(bool isAm) async =>
      await _schedulerApiClient.getAllSessions();

  bool getSessionAvailable({
    required ClassSession correspondingClass,
    required StudentSchedule schedule,
  }) =>
      !schedule.sessions.any(
        (session) =>
            correspondingClass.timeSession.time == session.timeSession.time,
      ) &&
      !schedule.sessions.any(
        (session) =>
            session.career.excelNum == correspondingClass.career.excelNum,
      );

  void _consolidateClasses({
    required List<Career> careers,
    required List<TimeSession> sessions,
  }) {
    // Identify the placeholder career and first session
    int placeholderCareerExcelNum = 86; // Replace with actual excelNum
    Career? placeholderCareer = careers.firstWhereOrNull(
      (career) => career.excelNum == placeholderCareerExcelNum,
    );
    TimeSession? firstSession = sessions.isNotEmpty ? sessions.first : null;

    // Group classes by career and time session
    var groupedClasses = groupBy(
      classes,
      (ClassSession cs) => '${cs.career.id}-${cs.timeSession.time}',
    );

    List<ClassSession> newClasses = [];

    for (var group in groupedClasses.values) {
      Career career = group.first.career;
      TimeSession timeSession = group.first.timeSession;

      // Skip consolidation for the placeholder class in the first session
      if (career.id == placeholderCareer?.id &&
          timeSession.time == firstSession?.time) {
        newClasses.addAll(group);
        continue;
      }

      // Merge students from all classes in the group
      List<Student> allStudents = group.expand((cs) => cs.students).toList();

      // If total students are less than minClassSize, handle accordingly
      if (allStudents.length < career.minClassSize) {
        // Mark career-session as under-enrolled
        // Handle later (e.g., reassign students)
        continue;
      }

      // Determine the number of classes needed based on min and max class sizes
      int numberOfClasses = (allStudents.length / career.maxClassSize).ceil();

      // Adjust number of classes to ensure classes meet minClassSize
      while (numberOfClasses > 1 &&
          (allStudents.length / numberOfClasses) < career.minClassSize) {
        numberOfClasses--;
      }

      // Split students into new classes
      for (int i = 0; i < numberOfClasses; i++) {
        List<Student> classStudents = allStudents
            .skip(i * (allStudents.length / numberOfClasses).ceil())
            .take((allStudents.length / numberOfClasses).ceil())
            .toList();

        ClassSession newClass = ClassSession(
          timeSession: timeSession,
          career: career,
          students: classStudents,
          uniqueId: _uuid.v4(),
        );
        newClasses.add(newClass);

        // Update student schedules
        for (Student student in classStudents) {
          StudentSchedule? schedule = studentSchedules
              .firstWhereOrNull((s) => s.student.id == student.id);
          if (schedule != null) {
            // Remove old class sessions for this time and career
            schedule.sessions.removeWhere((cs) =>
                cs.career.id == career.id &&
                cs.timeSession.time == timeSession.time,);
            schedule.sessions.add(newClass);
          }
        }
      }
    }

    // Replace old classes with new consolidated classes
    classes = newClasses;
  }

  void _balanceOvercrowdedClasses(
      {required List<Career> careers, required List<TimeSession> sessions,}) {
    // Identify the placeholder career and first session
    int placeholderCareerExcelNum = 86; // Replace with actual excelNum
    Career? placeholderCareer = careers.firstWhereOrNull(
      (career) => career.excelNum == placeholderCareerExcelNum,
    );
    TimeSession? firstSession = sessions.isNotEmpty ? sessions.first : null;

    for (ClassSession cs in classes) {
      // Skip the placeholder class in the first session
      if (cs.career.id == placeholderCareer?.id &&
          cs.timeSession.time == firstSession?.time) {
        continue;
      }

      if (cs.students.length > cs.career.maxClassSize) {
        int overflow = cs.students.length - cs.career.maxClassSize;
        List<Student> studentsToReassign = cs.students.take(overflow).toList();
        cs.students.removeRange(0, overflow);

        for (Student student in studentsToReassign) {
          // Find another class for this student
          ClassSession? alternativeClass = classes.firstWhereOrNull(
            (c) =>
                c.career.id == cs.career.id &&
                c.timeSession.time == cs.timeSession.time &&
                !c.isFull &&
                c.uniqueId != cs.uniqueId,
          );

          if (alternativeClass != null) {
            alternativeClass.students.add(student);

            // Update student schedule
            StudentSchedule? schedule = studentSchedules
                .firstWhereOrNull((s) => s.student.id == student.id);
            if (schedule != null) {
              schedule.sessions.remove(cs);
              schedule.sessions.add(alternativeClass);
            }
          }
        }
      }
    }
  }

  void _handleUnderEnrolledClasses({
    required List<Career> careers,
    required List<TimeSession> sessions,
  }) {
    const int placeholderCareerExcelNum = 86; // Replace with actual excelNum
    final Career? placeholderCareer = careers.firstWhereOrNull(
      (career) => career.excelNum == placeholderCareerExcelNum,
    );
    List<ClassSession> underEnrolledClasses = classes.where((cs) {
      return cs.students.length < cs.career.minClassSize;
    }).toList();

    for (ClassSession cs in underEnrolledClasses) {
      // Remove class from classes list
      classes.remove(cs);

      // Reassign students to their next preferred careers
      for (Student student in cs.students) {
        StudentSchedule? schedule =
        studentSchedules.firstWhereOrNull((s) => s.student.id == student.id);

        if (schedule != null) {
          schedule.sessions.remove(cs);

          // Try to assign to next preferred career
          bool reassigned = false;
          for (int priority = 0; priority < 5; priority++) {
            int careerId = getCareerId(index: priority, student: student);
            Career? priorityCareer =
            careers.firstWhereOrNull((career) => career.excelNum == careerId);

            if (priorityCareer == null ||
                priorityCareer.id == cs.career.id ||
                (student.school == 'NOHS' &&
                    priorityCareer.id ==
                        placeholderCareer?.id)) {
              continue;
            }

            List<ClassSession> availableClasses = classes
                .where(
                  (session) =>
              session.career.id == priorityCareer.id &&
                  !session.isFull &&
                  getSessionAvailable(
                    correspondingClass: session,
                    schedule: schedule,
                  ),
            )
                .toList();

            if (availableClasses.isNotEmpty) {
              ClassSession targetClass = availableClasses.first;
              targetClass.students.add(student);
              schedule.sessions.add(targetClass);
              reassigned = true;
              break;
            }
          }

          // If unable to reassign based on preferences, assign to any available class
          if (!reassigned) {
            _finalAssignmentForStudent(
                schedule: schedule, excludeCareers: [cs.career.id],);
          }
        }
      }
    }
  }
  void _finalAssignmentForStudent({
    required StudentSchedule schedule,
    List<String>? excludeCareers,
  }) {
    List<ClassSession> availableClasses = classes
        .where((cs) =>
    !cs.isFull &&
        getSessionAvailable(correspondingClass: cs, schedule: schedule) &&
        !(excludeCareers?.contains(cs.career.id) ?? false),)
        .toList();

    // Sort available classes by the fewest number of students to balance class sizes
    availableClasses.sort((a, b) => a.students.length.compareTo(b.students.length));

    for (ClassSession cs in availableClasses) {
      cs.students.add(schedule.student);
      schedule.sessions.add(cs);

      if (schedule.isFull) break;
    }
  }

}
