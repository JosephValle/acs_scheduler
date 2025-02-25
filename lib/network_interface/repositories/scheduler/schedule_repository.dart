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
      for (final school in schools) school.shortName: school,
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
    );
    _generateClasses(careers: careers, sessions: sessions, students: students);
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
      final List<ExportStudentSchedule> exportStudentSchedule = [];
      for (final StudentSchedule schedule in studentSchedules) {
        final List<ExportStudentSession> exportStudentSessions = [];
        for (final ClassSession session in schedule.sessions) {
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

      final List<ExportCareerSchedule> exportCareerSchedule = [];
      for (final Career career in careers) {
        final List<ClassSession> sessions =
            classes.where((element) => element.career.id == career.id).toList();
        final List<int> counts = [0, 0, 0];
        final List<List<Student>> students = [[], [], []];
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

      final List<Map<String, dynamic>> studentExport = [];
      for (final ExportStudentSchedule student in exportStudentSchedule) {
        studentExport.add(student.toJson());
      }
      debugPrint(
        'Done Creating Student export json: ${stopwatch.elapsedMilliseconds} ms in',
      );

      final List<Map<String, dynamic>> careerExport = [];
      for (final ExportCareerSchedule career in exportCareerSchedule) {
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
      final WriteBatch batch = FirebaseFirestore.instance.batch();
      for (final DocumentSnapshot ds in snapshot.docs) {
        batch.delete(ds.reference);
      }
      await batch.commit();
    } while (snapshot.docs.isNotEmpty);
  }

  Future<void> _batchUpload(
    CollectionReference collection,
    List<Map<String, dynamic>> data,
  ) async {
    final WriteBatch batch = FirebaseFirestore.instance.batch();
    for (final item in data) {
      final DocumentReference docRef = collection.doc();
      batch.set(docRef, item);
    }
    await batch.commit();
  }

  void _finalCleanUp() {
    studentSchedules.sort((a, b) {
      final int schoolCompare = a.student.school.compareTo(b.student.school);
      if (schoolCompare != 0) return schoolCompare;

      final int lastNameCompare =
          a.student.lastName.compareTo(b.student.lastName);
      if (lastNameCompare != 0) return lastNameCompare;

      return a.student.firstName.compareTo(b.student.firstName);
    });
  }

  void _finalAssignment() {
    final List<StudentSchedule> remainingSchedules =
        studentSchedules.where((element) => !element.isFull).toList();

    for (final StudentSchedule schedule in remainingSchedules) {
      final List<ClassSession> availableClasses = classes
          .where(
            (cs) =>
                !cs.isFull &&
                getSessionAvailable(correspondingClass: cs, schedule: schedule),
          )
          .toList();

      // Sort available classes by the fewest number of students to balance class sizes
      availableClasses
          .sort((a, b) => a.students.length.compareTo(b.students.length));

      for (final ClassSession cs in availableClasses) {
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
    final List<StudentSchedule> partiallyFilledSchedules =
        studentSchedules.where((schedule) => !schedule.isFull).toList();
    for (final StudentSchedule schedule in partiallyFilledSchedules) {
      // Revisit each student's career priorities for remaining open slots
      for (int priority = 0; priority < 5; priority++) {
        final int careerId =
            getCareerId(index: priority, student: schedule.student);
        final Career? priorityCareer =
            careers.firstWhereOrNull((career) => career.excelNum == careerId);

        if (priorityCareer == null) {
          continue;
        }

        final List<ClassSession> availableClasses = classes
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

        for (final ClassSession classSession in availableClasses) {
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
    final Map<String, int> careerDemand = {};

    // Calculate demand for each career based on student preferences
    for (final Student student in students) {
      if (student.lastName == 'Acevedo') {
        print('Found Acevedo');
      }
      for (int i = 0; i < 5; i++) {
        final int careerId = getCareerId(index: i, student: student);
        careerDemand[careerId.toString()] =
            (careerDemand[careerId.toString()] ?? 0) + 1;
      }
    }

    for (final Career career in careers) {
      final int demand = careerDemand[career.excelNum.toString()] ?? 0;

      // Calculate the maximum number of classes that can meet minClassSize
      final int maxClassesBasedOnMinSize =
          (demand / career.minClassSize).floor();
      final int numberOfClasses = maxClassesBasedOnMinSize > 0
          ? maxClassesBasedOnMinSize
          : 1; // Ensure at least one class is created if there's any demand

      for (final TimeSession session in sessions) {
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
    const int placeholderCareerExcelNum = 86; // Replace with actual excelNum
    final Career? placeholderCareer = careers.firstWhereOrNull(
      (career) => career.excelNum == placeholderCareerExcelNum,
    );

    // Identify the first session
    final TimeSession? firstSession =
        sessions.isNotEmpty ? sessions.first : null;

    for (final Student student in students) {
      final StudentSchedule schedule = StudentSchedule(
        uniqueId: _uuid.v4(),
        sessionCount: sessions.length,
        student: student,
        sessions: [],
      );

      if (student.school == 'NOHS' &&
          placeholderCareer != null &&
          firstSession != null) {
        // Assign NOHS students to the placeholder class in the first session
        final ClassSession? placeholderClass = classes.firstWhereOrNull(
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
                    correspondingClass: element,
                    schedule: schedule,
                  ),
            )
            .toList()
          ..sort((a, b) => a.students.length.compareTo(b.students.length));

        for (final ClassSession correspondingClass in correspondingClasses) {
          if (getSessionAvailable(
            correspondingClass: correspondingClass,
            schedule: schedule,
          )) {
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
    const int placeholderCareerExcelNum = 86; // Replace with actual excelNum
    final Career? placeholderCareer = careers.firstWhereOrNull(
      (career) => career.excelNum == placeholderCareerExcelNum,
    );
    final TimeSession? firstSession =
        sessions.isNotEmpty ? sessions.first : null;

    // Group classes by career and time session
    final groupedClasses = groupBy(
      classes,
      (ClassSession cs) => '${cs.career.id}-${cs.timeSession.time}',
    );

    final List<ClassSession> newClasses = [];

    for (final group in groupedClasses.values) {
      final Career career = group.first.career;
      final TimeSession timeSession = group.first.timeSession;

      // Skip consolidation for the placeholder class in the first session
      if (career.id == placeholderCareer?.id &&
          timeSession.time == firstSession?.time) {
        newClasses.addAll(group);
        continue;
      }

      // Merge students from all classes in the group
      final List<Student> allStudents =
          group.expand((cs) => cs.students).toList();

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
        final List<Student> classStudents = allStudents
            .skip(i * (allStudents.length / numberOfClasses).ceil())
            .take((allStudents.length / numberOfClasses).ceil())
            .toList();

        final ClassSession newClass = ClassSession(
          timeSession: timeSession,
          career: career,
          students: classStudents,
          uniqueId: _uuid.v4(),
        );
        newClasses.add(newClass);

        // Update student schedules
        for (final Student student in classStudents) {
          final StudentSchedule? schedule = studentSchedules
              .firstWhereOrNull((s) => s.student.id == student.id);
          if (schedule != null) {
            // Remove old class sessions for this time and career
            schedule.sessions.removeWhere(
              (cs) =>
                  cs.career.id == career.id &&
                  cs.timeSession.time == timeSession.time,
            );
            schedule.sessions.add(newClass);
          }
        }
      }
    }

    // Replace old classes with new consolidated classes
    classes = newClasses;
  }

  void _balanceOvercrowdedClasses({
    required List<Career> careers,
    required List<TimeSession> sessions,
  }) {
    // Identify the placeholder career and first session
    const int placeholderCareerExcelNum = 86; // Replace with actual excelNum
    final Career? placeholderCareer = careers.firstWhereOrNull(
      (career) => career.excelNum == placeholderCareerExcelNum,
    );
    final TimeSession? firstSession =
        sessions.isNotEmpty ? sessions.first : null;

    for (final ClassSession cs in classes) {
      // Skip the placeholder class in the first session
      if (cs.career.id == placeholderCareer?.id &&
          cs.timeSession.time == firstSession?.time) {
        continue;
      }

      if (cs.students.length > cs.career.maxClassSize) {
        final int overflow = cs.students.length - cs.career.maxClassSize;
        final List<Student> studentsToReassign =
            cs.students.take(overflow).toList();
        cs.students.removeRange(0, overflow);

        for (final Student student in studentsToReassign) {
          // Find another class for this student
          final ClassSession? alternativeClass = classes.firstWhereOrNull(
            (c) =>
                c.career.id == cs.career.id &&
                c.timeSession.time == cs.timeSession.time &&
                !c.isFull &&
                c.uniqueId != cs.uniqueId,
          );

          if (alternativeClass != null) {
            alternativeClass.students.add(student);

            // Update student schedule
            final StudentSchedule? schedule = studentSchedules
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
    final List<ClassSession> underEnrolledClasses = classes.where((cs) {
      return cs.students.length < cs.career.minClassSize;
    }).toList();

    for (final ClassSession cs in underEnrolledClasses) {
      // Remove class from classes list
      classes.remove(cs);

      // Reassign students to their next preferred careers
      for (final Student student in cs.students) {
        final StudentSchedule? schedule = studentSchedules
            .firstWhereOrNull((s) => s.student.id == student.id);

        if (schedule != null) {
          schedule.sessions.remove(cs);

          // Try to assign to next preferred career
          bool reassigned = false;
          for (int priority = 0; priority < 5; priority++) {
            final int careerId = getCareerId(index: priority, student: student);
            final Career? priorityCareer = careers
                .firstWhereOrNull((career) => career.excelNum == careerId);

            if (priorityCareer == null ||
                priorityCareer.id == cs.career.id ||
                (student.school == 'NOHS' &&
                    priorityCareer.id == placeholderCareer?.id)) {
              continue;
            }

            final List<ClassSession> availableClasses = classes
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
              final ClassSession targetClass = availableClasses.first;
              targetClass.students.add(student);
              schedule.sessions.add(targetClass);
              reassigned = true;
              break;
            }
          }

          // If unable to reassign based on preferences, assign to any available class
          if (!reassigned) {
            _finalAssignmentForStudent(
              schedule: schedule,
              excludeCareers: [cs.career.id],
            );
          }
        }
      }
    }
  }

  void _finalAssignmentForStudent({
    required StudentSchedule schedule,
    List<String>? excludeCareers,
  }) {
    final List<ClassSession> availableClasses = classes
        .where(
          (cs) =>
              !cs.isFull &&
              getSessionAvailable(correspondingClass: cs, schedule: schedule) &&
              !(excludeCareers?.contains(cs.career.id) ?? false),
        )
        .toList();

    // Sort available classes by the fewest number of students to balance class sizes
    availableClasses
        .sort((a, b) => a.students.length.compareTo(b.students.length));

    for (final ClassSession cs in availableClasses) {
      cs.students.add(schedule.student);
      schedule.sessions.add(cs);

      if (schedule.isFull) break;
    }
  }
}
