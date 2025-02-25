import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'school.g.dart';

/// This is the object that represents a school in our system
///
/// [id] is their firebase uid and unique identifier in general
/// [name] is the long form name of the school
/// [shortName] is the internal abbreviation of the school name
/// [category] is the classification of the school
/// [imageUrl] is the url of the header image of the school
/// [studentCount] is the amount of students currently active in the school
/// [activeCareerCount] is the amount of careers currently active for the school
/// [classroomCount] is the number of class rooms the school currently have set
///
/// {@category School}
/// {@subCategory objects}
///
@JsonSerializable()
@HiveType(typeId: 1)
class School extends HiveObject {
  @HiveField(0)

  /// [id] is their firebase uid and unique identifier in general
  final String id;

  @HiveField(1)

  /// [name] is the long form name of the school
  final String name;

  @HiveField(2)

  /// [shortName] is the internal abbreviation of the school name
  final String shortName;

  @HiveField(3)

  /// [category] is the classification of the school
  final String category;

  @HiveField(4)
  @JsonKey(defaultValue: '')

  /// [imageUrl] is the url of the header image of the school
  final String imageUrl;

  @HiveField(5)
  @JsonKey(defaultValue: 0)

  /// [studentCount] is the amount of students currently active in the school
  final int studentCount;

  @HiveField(6)
  @JsonKey(defaultValue: 0)

  /// [activeCareerCount] is the amount of careers currently active for the school
  final int activeCareerCount;

  @HiveField(7)
  @JsonKey(defaultValue: 0)

  /// [classroomCount] is the number of class rooms the school currently have set
  final int classroomCount;
  @HiveField(8)
  @JsonKey(defaultValue: 'AM')

  /// [time] am or pm
  final String time;

  School({
    required this.category,
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.activeCareerCount,
    required this.classroomCount,
    required this.shortName,
    required this.studentCount,
    required this.time,
  });

  // copyWith method
  School copyWith({
    String? id,
    String? name,
    String? shortName,
    String? category,
    String? imageUrl,
    int? studentCount,
    int? activeCareerCount,
    int? classroomCount,
    String? time,
  }) {
    return School(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      studentCount: studentCount ?? this.studentCount,
      activeCareerCount: activeCareerCount ?? this.activeCareerCount,
      classroomCount: classroomCount ?? this.classroomCount,
      time: time ?? this.time,
    );
  }

  factory School.fromJson(Map<String, dynamic> json) => _$SchoolFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolToJson(this);
}
