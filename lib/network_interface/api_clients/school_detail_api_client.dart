import 'package:adams_county_scheduler/objects/career.dart';
import 'package:adams_county_scheduler/objects/room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../collection_names.dart';

class SchoolDetailsApiClient {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Career>> loadCareers({required String schoolId}) async {
    return (await _firestore
            .collection('$schoolsCollection/$schoolId/$careersCollection')
            .get())
        .docs
        .map<Career>((e) => Career.fromJson(e.data()))
        .toList();
  }

  Future<List<dynamic>> loadStudents({required String schoolId}) async {
    return (await _firestore
            .collection('$schoolsCollection/$schoolId/$studentsCollection')
            .get())
        .docs
        .map<Career>((e) => Career.fromJson(e.data()))
        .toList();
  }

  Future<List<Room>> loadRooms({required String schoolId}) async {
    return (await _firestore
            .collection('$schoolsCollection/$schoolId/rooms')
            .get())
        .docs
        .map<Room>((e) => Room.fromJson(e.data()))
        .toList();
  }

  Future<Room> createRoom({
    required String schoolId,
    required String name,
    required String building,
    required int maxSize,
    required int? minSize,
  }) async {
    DocumentReference ref =
        await _firestore.collection('$schoolsCollection/$schoolId/rooms').add({
      'name': name,
      'building': building,
      'minSize': minSize ?? 0,
      'maxSize': maxSize,
    });

    await ref.update({'id': ref.id});

    await _firestore
        .collection(schoolsCollection)
        .doc(schoolId)
        .update({'classroomCount': FieldValue.increment(1)});

    return Room(
      name: name,
      id: ref.id,
      building: building,
      maxSize: maxSize,
      minSize: minSize ?? 0,
    );
  }
}
