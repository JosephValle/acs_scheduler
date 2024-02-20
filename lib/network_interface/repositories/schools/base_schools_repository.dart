import 'dart:async';

import 'package:image_picker/image_picker.dart';

import '../../../objects/school.dart';


///This repo is used to interact with schools from our database
abstract class BaseSchoolsRepository {

  /// This is used to create a new school
  ///
  /// [schoolName] is the full name of the school
  /// [schoolShortName] is the abbreviation of the school name
  /// [imageUrl] is the optional link to the selected image
  /// [category] is the classification of the school
  Future<School> createSchool({
    required String schoolName,
    required String schoolShortName,
    required String category,
    required String? imageUrl,
    required String time,
  });


  ///This is used to upload an image for a school
  ///
  /// [schoolShortName] is the abbreviation where we will store it
  /// [image] is the image to upload
  /// [onFinished] is the event that is called when you complete the upload
  /// [onProgress] provides a percentage upload progress double
  Future<void> uploadSchoolImage(
      {required String schoolShortName,
        required XFile image,
        required Function(String downloadLink) onFinished,
        required Function(double progress) onProgress,});

  ///Load all available schools
  Future<List<School>> loadSchools();
}
