import 'package:adams_county_scheduler/network_interface/collection_names.dart';
import 'package:adams_county_scheduler/objects/time_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docx_template/docx_template.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_excel/excel.dart';
import 'package:intl/intl.dart';

import '../../objects/export_careers_schedule.dart';
import '../../objects/export_student_schedule.dart';
import '../../objects/report.dart';
import '../../objects/student.dart';
import '../../utilities/functions/format_timestamp.dart';

class SchedulerApiClient {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<TimeSession> createSession({
    required DateTime time,
    required String session,
  }) async {
    DocumentReference ref =
        await _firestore.collection(sessionsCollection).add({
      'time': Timestamp.fromDate(time),
      'session': session,
    });

    await ref.update({'id': ref.id});

    return TimeSession(
      id: ref.id,
      time: Timestamp.fromDate(time),
      session: session,
    );
  }

  Future<void> deleteSession(String sessionId) async {
    await _firestore.collection(sessionsCollection).doc(sessionId).delete();
  }

  Future<List<TimeSession>> getAllSessions() async {
    QuerySnapshot querySnapshot = await _firestore
        .collection(sessionsCollection)
        .orderBy('time', descending: false) // Order by time in ascending order
        .get();

    return querySnapshot.docs
        .map(
          (doc) => TimeSession.fromJson(
            doc.data() as Map<String, dynamic>,
          ),
        ) // Assign the document ID to the TimeSession id field
        .toList();
  }

  Future<List<ReportLink>> getAllReports() async {
    const String directory = 'reports';
    List<ReportLink> reportLinks = [];
    Reference dirRef = storage.ref(directory);
    ListResult result = await dirRef.listAll();
    for (var ref in result.items) {
      String url = await ref.getDownloadURL();
      reportLinks.add(ReportLink(filename: ref.name, downloadUrl: url));
    }
    return reportLinks;
  }

  Future<String> createCareerCounts({
    required List<ExportCareerSchedule> careers,
    required String time,
  }) async {
    try {
      var excel = Excel.createExcel(); // Create an Excel document
      careers.sort((a, b) => a.career.compareTo(b.career));
      Sheet sheetObject = excel['Sheet1']; // Accessing sheet

      // Create the headers
      List<String> headers = [
        'Id',
        'Name',
        'Room',
        'Session 1',
        'Session 2',
        'Session 3',
      ];
      sheetObject.appendRow(headers);

      // Iterate over the schedules and fill the data
      for (var career in careers) {
        List<dynamic> row = [
          career.excelId,
          career.career,
          career.room,
        ];

        // Assuming there are always 3 sessions
        for (int session in career.sessionCounts) {
          row.add(session);
        }

        sheetObject.appendRow(row);
      }

      // Save the Excel file
      Uint8List fileBytes = Uint8List.fromList(excel.encode()!);
      String fileName = 'Career Counts List - $time.xlsx';

      return await uploadFile(fileBytes, fileName);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> createMasterList({
    required List<ExportStudentSchedule> schedules,
    required String time,
  }) async {
    var excel = Excel.createExcel(); // Create an Excel document
    Sheet sheetObject = excel['Sheet1']; // Accessing sheet

    // Create the headers
    List<String> headers = [
      'School',
      'Name',
      'Session 1',
      'Session 2',
      'Session 3',
    ];
    sheetObject.appendRow(headers);

    // Iterate over the schedules and fill the data
    for (var schedule in schedules) {
      List<String> row = [
        schedule.school,
        schedule.formattedName,
      ];

      // Assuming there are always 3 sessions
      for (var session in schedule.sessions) {
        row.add(session.careerName);
      }

      sheetObject.appendRow(row);
    }

    // Save the Excel file
    Uint8List fileBytes = Uint8List.fromList(excel.encode()!);
    String fileName = 'Master List - $time.xlsx';

    return await uploadFile(fileBytes, fileName);
  }

  Future<String> createStudentSchedule({
    required List<ExportStudentSchedule> schedules,
    required String time,
  }) async {
    try {
      final ByteData data = await rootBundle
          .load('assets/templates/student_schedule_template.docx');
      final Uint8List bytes = data.buffer.asUint8List();
      final docx = await DocxTemplate.fromBytes(bytes);

      Content c = Content();
      List<Content> plainContents = [];

      for (ExportStudentSchedule schedule in schedules) {
        List<RowContent> rows = [];
        // Sort them based on time,
        // Format is HH:MM AM/PM
        schedule.sessions.sort((a, b) {
          // Parse the time strings into DateTime objects for comparison
          DateFormat dateFormat = DateFormat('hh:mm a'); // Using the DateFormat class from the intl package
          DateTime timeA = dateFormat.parse(a.time);
          DateTime timeB = dateFormat.parse(b.time);
          return timeA.compareTo(timeB); // Compare the DateTime objects to sort
        });
        for (var session in schedule.sessions) {
          rows.add(
            RowContent()
              ..add(TextContent('key1', session.time))
              ..add(TextContent('key2', session.careerName))
              ..add(TextContent('key3', session.roomName)),
          );
        }
        plainContents.add(
          PlainContent('plainview')
            ..add(TextContent('school', schedule.school))
            ..add(TextContent('student', schedule.formattedName))
            ..add(TableContent('table', rows)),
        );
      }
      c.add(ListContent('plainlist', plainContents));
      final Uint8List d = Uint8List.fromList((await docx.generate(c))!);
      final String fileName = 'Student Schedules - $time.docx';
      return await uploadFile(d, fileName);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> createAttendanceSchedule({
    required List<ExportCareerSchedule> careerSessions,
    required List<TimeSession> times,
    required String time,
  }) async {
    try {
      final ByteData data = await rootBundle
          .load('assets/templates/career_attendance_template.docx');
      final Uint8List bytes = data.buffer.asUint8List();
      final docx = await DocxTemplate.fromBytes(bytes);
      careerSessions.sort((a, b) => a.career.compareTo(b.career));
      Content c = Content();
      List<Content> plainContents = [];

      for (ExportCareerSchedule session in careerSessions) {
        for (int i = 0; i < times.length; i++) {
          final List<Student> students = session.students[i];
          if (students.isEmpty) continue;
          final TimeSession time = times[i];
          students.sort(
            (a, b) => '${a.lastName}, ${a.firstName}'
                .compareTo('${b.lastName}, ${b.firstName}'),
          );
          List<RowContent> rows = [];
          // Handles up to 65 students in one class while also
          // Exporting the documents all on one sheet
          const int increment = 25;
          int number = 20;

          while (students.length > number) {
            number += increment;
          }

          for (int j = 0; j < number; j++) {
            Student? student;
            try {
              student = students[j];
            } catch (_) {}
            rows.add(
              RowContent()
                ..add(TextContent('key1', student?.school ?? ''))
                ..add(
                  TextContent(
                    'key2',
                    student == null
                        ? ''
                        : '${student.lastName}, ${student.firstName}',
                  ),
                ),
            );
          }
          plainContents.add(
            PlainContent('plainview')
              ..add(TextContent('career', session.career))
              ..add(TextContent('room', session.room))
              ..add(TextContent('time', formatTimestamp(time.time)))
              ..add(TableContent('table', rows)),
          );
        }
      }
      c.add(ListContent('plainlist', plainContents));
      final Uint8List d = Uint8List.fromList((await docx.generate(c))!);
      final String fileName = 'Career Attendance - $time.docx';
      return await uploadFile(d, fileName);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadFile(Uint8List fileBytes, String fileName) async {
    try {
      final Reference ref = FirebaseStorage.instance.ref('/reports/$fileName');

      final UploadTask uploadTask = ref.putData(fileBytes);

      await uploadTask.whenComplete(() => {});

      final String downloadURL = await ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      debugPrint('Error uploading $fileName: $e');
      rethrow;
    }
  }
}
