import 'package:adams_county_scheduler/objects/career_priority.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'student.g.dart';

/// This is the profile used for the current user and some basic info about them
///
/// [id] is their firebase uid and unique identifier in general
/// [school] is the name of the school associated with the user
/// [firstName] is the first name of the student
/// [lastName] is the last name of the student
/// [careerPriority] is the priority list of the students career day choices. See [CareerPriority] for details
/// [grade] is the grade as an integer of the student
///
/// {@category Student}
/// {@subCategory objects}

@JsonSerializable()
@HiveType(typeId: 4)
class Student extends HiveObject {
  @HiveField(0)

  /// [id] is their firebase uid and unique identifier in general
  final String id;

  @HiveField(1)

  /// [school] is the name of the school associate with the user
  final String school;

  @HiveField(2)

  /// [firstName] is the first name of the student
  final String firstName;

  @HiveField(3)

  /// [lastName] is the last name of the student
  final String lastName;

  @HiveField(4)
  @JsonKey(fromJson: _careerPriorityFromJson, toJson: _careerPriorityToJson)
  @HiveField(5)

  /// [careerPriority] is the priority list of the students career day choices. See [CareerPriority] for details
  final CareerPriority careerPriority;

  @HiveField(6)
  @JsonKey(defaultValue: -1)

  /// [grade] is the grade as an integer of the student
  final int grade;

  @HiveField(7)

  /// [schoolId] is the students school's Id
  final String schoolId;

  Student(
      {required this.id,
      required this.school,
      required this.firstName,
      required this.lastName,
      required this.careerPriority,
      required this.grade,
      required this.schoolId,});

  factory Student.fromJson(Map<String, dynamic> json) =>
      _$StudentFromJson(json);

  Map<String, dynamic> toJson() => _$StudentToJson(this);

  static CareerPriority _careerPriorityFromJson(Map<String, dynamic> data) =>
      CareerPriority.fromJson(data);

  static Map<String, dynamic> _careerPriorityToJson(CareerPriority careerPriority) =>
      careerPriority.toJson();
}
