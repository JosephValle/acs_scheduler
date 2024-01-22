import 'package:adams_county_scheduler/objects/career_priority.dart';
import 'package:adams_county_scheduler/objects/school.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../../objects/student.dart';
import '../collection_names.dart';

class StudentApiClient {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Student> createStudent({
    required String firstName,
    required String lastName,
    required CareerPriority careerPriority,
    required String school,
    required String schoolId,
    required int grade,
  }) async {
    DocumentReference ref =
        await _firestore.collection(studentsCollection).add({
      'firstName': firstName,
      'lastName': lastName,
      'careerPriority': careerPriority.toJson(),
      'school': school,
      'schoolId': schoolId,
      'grade': grade,
    });
    await ref.update({'id': ref.id});

    await _firestore
        .collection(schoolsCollection)
        .doc(schoolId)
        .update({'studentCount': FieldValue.increment(1)});

    return Student(
      id: ref.id,
      school: school,
      firstName: firstName,
      lastName: lastName,
      careerPriority: careerPriority,
      grade: grade,
      schoolId: schoolId,
    );
  }

  Future<List<Student>> getStudents() async {
    return (await _firestore.collection(studentsCollection).get())
        .docs
        .map<Student>((e) => Student.fromJson(e.data()))
        .toList();
  }

  Future<List<Student>> getStudentBySchool({required String schoolId}) async {
    return (await _firestore
            .collection(studentsCollection)
            .where('schoolId', isEqualTo: schoolId)
            .get())
        .docs
        .map<Student>((e) => Student.fromJson(e.data()))
        .toList();
  }

  Future<String> getSchoolIdByName({required String schoolName}) async {
    return (await _firestore
            .collection(schoolsCollection)
            .where('name', isEqualTo: schoolName)
            .get())
        .docs
        .map((e) => School.fromJson(e.data()))
        .toList()
        .firstWhere((element) => element.name == schoolName)
        .id;
  }

  Future<void> clearAllStudents() async {
    WriteBatch batch = _firestore.batch();
    int operationCount = 0;

    try {
      // Delete students
      QuerySnapshot studentsSnapshot =
          await _firestore.collection('students').get();
      for (var doc in studentsSnapshot.docs) {
        batch.delete(doc.reference);
        operationCount++;

        if (operationCount == 500) {
          batch.commit();
          batch = _firestore.batch();
          operationCount = 0;
        }
      }

      if (operationCount > 0) {
        await batch.commit();
      }

      // Reset studentCount in schools
      QuerySnapshot schoolsSnapshot =
          await _firestore.collection('schools').get();
      for (var doc in schoolsSnapshot.docs) {
        _firestore
            .collection('schools')
            .doc(doc.id)
            .update({'studentCount': 0});
      }
    } catch (e) {
      debugPrint('Error in clearAllStudents: $e');
      rethrow;
    }
  }
}
