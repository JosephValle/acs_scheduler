import 'package:adams_county_scheduler/network_interface/api_clients/careers_api_client.dart';
import 'package:adams_county_scheduler/network_interface/api_clients/schools_api_client.dart';
import 'package:adams_county_scheduler/network_interface/api_clients/students_api_client.dart';
import 'package:adams_county_scheduler/network_interface/repositories/scheduler/base_schedule_repository.dart';
import 'package:adams_county_scheduler/objects/class_session.dart';
import 'package:adams_county_scheduler/objects/export_careers_schedule.dart';
import 'package:adams_county_scheduler/objects/export_student_schedule.dart';
import 'package:adams_county_scheduler/objects/school.dart';
import 'package:adams_county_scheduler/objects/student_schedule.dart';
import 'package:adams_county_scheduler/utilities/functions/format_timestamp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';
import '../../../objects/career.dart';
import '../../../objects/student.dart';
import '../../../objects/time_session.dart';
import '../../api_clients/scheduler_api_client.dart';

class ScheduleRepository extends BaseScheduleRepository {
  final SchedulerApiClient _schedulerApiClient = SchedulerApiClient();
  final Uuid _uuid = const Uuid();
  final Stopwatch stopwatch = Stopwatch();
  List<ClassSession> classes = [];
  List<StudentSchedule> studentSchedules = [];

  @override
  Future<void> generateSchedule(bool isAm) async {
    debugPrint('Start');
    stopwatch.reset();
    stopwatch.start();
    final String time = isAm ? 'AM' : 'PM';

    final List<Career> careers = await _getAllCareers();
    debugPrint(
      'Done downloading careers: ${stopwatch.elapsedMilliseconds} ms in',
    );
    final List<School> schools = await _getAllSchools();
    for (var school in schools) {
      print(school.shortName);
      print(school.time);
    }
    // Student objects have a field 'school' that corresponds to a school shortName
// Create a map of school shortName to School object for efficient lookup
    final Map<String, School> schoolMap = {
      for (var school in schools) school.shortName: school,
    };

    final List<Student> unfiltered = await _getAllStudents();
// Filter students where their school's time matches the `time` variable
    final List<Student> students = unfiltered.where((student) {
      // Use the student's school field to get the corresponding School object from the map
      final School? studentSchool = schoolMap[student.school];
      // Check if the school's time matches the specified time
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

    _generateClasses(careers: careers, sessions: sessions);
    _initialAssignment(
      students: students,
      careers: careers,
      sessions: sessions,
    );
    debugPrint('Done Initial Assign: ${stopwatch.elapsedMilliseconds} ms in');
    _cleanup();
    _secondaryAssignment();
    _removeSmallClasses();
    _finalAssignment();
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
        // TODO: Make them Correspond
        for (int i = 0; i < sessions.length; i += 1) {
          final ClassSession session = sessions[i];
          counts[i] = session.students.length;
          for (int j = 0; j < session.students.length; j++) {
            students[i].add(session.students[j]);
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
    }
  }

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
    for (StudentSchedule remainingSchedule in remainingSchedules) {
      while (!remainingSchedule.isFull) {
        for (ClassSession remainingClass in classes) {
          bool sessionAvailable = getSessionAvailable(
            correspondingClass: remainingClass,
            schedule: remainingSchedule,
          );
          if (!remainingClass.isFull && sessionAvailable) {
            remainingClass.students.add(remainingSchedule.student);
            remainingSchedule.sessions.add(remainingClass);
          }
        }
      }
    }
  }

  void _removeSmallClasses() {
    final List<ClassSession> notMin = classes
        .where(
          (element) => element.students.length < element.career.minClassSize,
    )
        .toList();
    for (var minClass in notMin) {
      for (StudentSchedule schedule in studentSchedules) {
        schedule.sessions
            .removeWhere((element) => element.uniqueId == minClass.uniqueId);
      }
      classes.removeWhere((element) => element.uniqueId == minClass.uniqueId);
    }
    classes.sort((a, b) => a.students.length.compareTo(b.students.length));
  }

  void _secondaryAssignment() {
    List<StudentSchedule> remainingSchedules =
    studentSchedules.where((element) => !element.isFull).toList();
    for (StudentSchedule remainingSchedule in remainingSchedules) {
      while (!remainingSchedule.isFull) {
        for (ClassSession remainingClass in classes) {
          bool sessionAvailable = getSessionAvailable(
            correspondingClass: remainingClass,
            schedule: remainingSchedule,
          );
          if (!remainingClass.isFull && sessionAvailable) {
            remainingClass.students.add(remainingSchedule.student);
            remainingSchedule.sessions.add(remainingClass);
          }
        }
      }
    }
  }

  void _cleanup() {
    classes.removeWhere((element) => element.students.isEmpty);
    classes.sort((a, b) => a.students.length.compareTo(b.students.length));
  }

  void _generateClasses({
    required List<Career> careers,
    required List<TimeSession> sessions,
  }) {
    for (Career career in careers) {
      for (TimeSession session in sessions) {
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

  void _initialAssignment({
    required List<Student> students,
    required List<Career> careers,
    required List<TimeSession> sessions,
  }) {
    for (Student student in students) {
      StudentSchedule schedule = StudentSchedule(
        uniqueId: _uuid.v4(),
        sessionCount: sessions.length,
        student: student,
        sessions: [],
      );
      for (int i = 0; i < 5; i++) {
        final int careerPriority = getCareerId(index: i, student: student);
        if (careerPriority <= 0) continue;
        final Career career =
        careers.firstWhere((element) => element.excelNum == careerPriority);
        final List<ClassSession> correspondingClasses =
        classes.where((element) => element.career.id == career.id).toList();
        for (ClassSession correspondingClass in correspondingClasses) {
          bool sessionAvailable = getSessionAvailable(
            correspondingClass: correspondingClass,
            schedule: schedule,
          );
          if (!correspondingClass.isFull && sessionAvailable) {
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

  Future<List<School>> _getAllSchools() async =>
      await SchoolsApiClient().loadSchools();

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
      );
}