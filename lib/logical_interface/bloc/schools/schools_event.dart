part of 'schools_bloc.dart';

@immutable
abstract class SchoolsEvent {}

class CreateSchool extends SchoolsEvent {
  final String schoolName;
  final String schoolShortName;
  final XFile? image;
  final String category;
  final String time;

  ///This event creates a new school and updates the UI accordingly
  ///[schoolName] is the full name of the school
  ///[schoolShortName] is the abbreviation of the school
  ///[category] is the classification of the school
  ///[image] is the optional header image
  CreateSchool({
    required this.time,
    required this.schoolShortName,
    required this.schoolName,
    required this.category,
    required this.image,
  });
}

class UploadSchool extends SchoolsEvent {
  final String schoolName;
  final String schoolShortName;
  final String? imageUrl;
  final String category;
  final String time;

  ///This event actually uploads the school and emits the events
  ///[schoolName] is the full name of the school
  ///[schoolShortName] is the abbreviation of the school
  ///[category] is the classification of the school
  ///[imageUrl] is the optional header image url
  UploadSchool({
    required this.time,
    required this.imageUrl,
    required this.schoolShortName,
    required this.schoolName,
    required this.category,
  });
}

class UploadProgressUpdated extends SchoolsEvent {
  final double progress;

  ///This handler allows us to avoid async conditions and emit an event for progress change
  UploadProgressUpdated({required this.progress});
}

///This is used to get all available schools
class LoadSchools extends SchoolsEvent {}