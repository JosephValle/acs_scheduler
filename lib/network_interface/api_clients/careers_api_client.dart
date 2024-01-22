import 'dart:async';

import 'package:adams_county_scheduler/objects/career.dart';
import 'package:adams_county_scheduler/objects/session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../collection_names.dart';

class CareersApiClient {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Career> createCareer({
    required String name,
    required String category,
    required List<String> speakers,
    required String room,
    required int excelNum,
    required int maxClassSize,
    required int minClassSize,
  }) async {
    DocumentReference ref = await _firestore.collection(careersCollection).add({
      'name': name,
      'category': category,
      'speakers': speakers,
      'createdAt': DateTime.now(),
      'maxClassSize': maxClassSize,
      'excelNum': excelNum,
      'room': room,
      'minClassSize': minClassSize,
    });

    await ref.update({'id': ref.id});

    return Career(
      id: ref.id,
      name: name,
      category: category,
      speakers: speakers,
      session: Session.Both,
      excelNum: excelNum,
      room: room,
      maxClassSize: maxClassSize,
      minClassSize: minClassSize,
    );
  }

  Future<List<Career>> loadCareers() async {
    return (await _firestore.collection(careersCollection).get())
        .docs
        .map<Career>((e) => Career.fromJson(e.data()))
        .toList();
  }

  Future<bool> checkCareerAddedToSchool({
    required String schoolId,
    required String careerId,
  }) async {
    DocumentSnapshot snap = await _firestore
        .collection('$schoolsCollection/$schoolId/$careersCollection')
        .doc(careerId)
        .get();

    return snap.exists;
  }

  Future<void> addCareerToSchool({
    required String schoolId,
    required Career career,
  }) async {
    await _firestore
        .collection('$schoolsCollection/$schoolId/$careersCollection')
        .doc(career.id)
        .set(career.toJson());

    await _updateCareerCount(schoolId: schoolId, count: 1);
  }

  Future<void> updateCareerSessionForSchool({
    required String schoolId,
    required String careerId,
    required Session session,
  }) async {
    await _firestore
        .collection('$schoolsCollection/$schoolId/$careersCollection')
        .doc(careerId)
        .update(
      {'session': describeEnum(session).toLowerCase()},
    );
  }

  Future<void> remoteCareerFromSchool({
    required String schoolId,
    required String careerId,
  }) async {
    await _firestore
        .collection('$schoolsCollection/$schoolId/$careersCollection')
        .doc(careerId)
        .delete();
    await _updateCareerCount(schoolId: schoolId, count: -1);
  }

  Future<void> _updateCareerCount({
    required String schoolId,
    required int count,
  }) async {
    FieldValue increment = FieldValue.increment(count);

    await _firestore
        .collection(schoolsCollection)
        .doc(schoolId)
        .update({'activeCareerCount': increment});
  }

  Future<void> deleteCareer(Career career) async {
    try {
      await _firestore.collection(careersCollection).doc(career.id).delete();
    } catch (e) {
      debugPrint('Error deleting career: $e');
    }
  }
}
