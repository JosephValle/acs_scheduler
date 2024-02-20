import 'dart:async';

import 'package:adams_county_scheduler/network_interface/api_clients/schools_api_client.dart';
import 'package:adams_county_scheduler/network_interface/repositories/schools/base_schools_repository.dart';
import 'package:adams_county_scheduler/objects/school.dart';
import 'package:image_picker/image_picker.dart';

class SchoolsRepository implements BaseSchoolsRepository {
  final SchoolsApiClient _schoolsApiClient = SchoolsApiClient();

  @override
  Future<School> createSchool({required String schoolName,
    required String schoolShortName,
    required String category,
    required String? imageUrl, required String time,}) async {
    return await _schoolsApiClient.createSchool(
      schoolName: schoolName,
      shortSchoolName: schoolShortName,
      time: time,
      imageUrl: imageUrl,
      category: category,);
  }

  @override
  Future<void> uploadSchoolImage({required String schoolShortName,
    required XFile image,
    required Function(String downloadLink) onFinished,
    required Function(double progress) onProgress,}) async {
    return await _schoolsApiClient.uploadSchoolImage(schoolShortName: schoolShortName,
      image: image,
      onProgress: onProgress,
      onFinished: onFinished,);
  }

  @override
  Future<List<School>> loadSchools() async{
    return await _schoolsApiClient.loadSchools();
  }
}
