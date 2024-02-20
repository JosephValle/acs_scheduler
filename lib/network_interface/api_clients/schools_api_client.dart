import 'dart:async';

import 'package:adams_county_scheduler/objects/school.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../collection_names.dart';

class SchoolsApiClient {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<School> createSchool({
    required String schoolName,
    required String shortSchoolName,
    required String? imageUrl,
    required String category,
    required String time,
  }) async {
    DocumentReference ref = await _firestore.collection(schoolsCollection).add({
      'name': schoolName,
      'shortName': shortSchoolName,
      'category': category,
      'imageUrl': imageUrl,
      'studentCount': 0,
      'activeCareerCount': 0,
      'classroomCount': 0,
      'time': time,
      'createdAt': DateTime.now(),
    });

    await ref.update({'id': ref.id});

    return School(
      category: category,
      id: ref.id,
      name: schoolName,
      imageUrl: imageUrl ?? '',
      activeCareerCount: 0,
      classroomCount: 0,
      shortName: shortSchoolName,
      studentCount: 0,
      time: time,);
  }

  Future<void> uploadSchoolImage({
    required String schoolShortName,
    required XFile image,
    required Function(double progress) onProgress,
    required Function(String downloadUrl) onFinished,
  }) async {
    Reference ref = _storage.ref('$schoolsCollection/header_images/').child(
      "${schoolShortName}_header_image.${image.mimeType!.split("/").last}",
    );

    UploadTask task = ref.putData(
      await image.readAsBytes(),
      SettableMetadata(contentType: image.mimeType),
    );

    task.asStream().listen((event) async {
      double progress = (100.0 *
          (event.bytesTransferred.toDouble() / event.totalBytes.toDouble()));
      onProgress(
        progress,
      );

      if (progress >= 100) {
        onFinished(await event.ref.getDownloadURL());
      }
    });
  }

  Future<List<School>> loadSchools() async {
    return (await _firestore.collection(schoolsCollection).get())
        .docs
        .map<School>((e) => School.fromJson(e.data()))
        .toList();
  }
}