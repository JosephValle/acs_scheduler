import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'room.g.dart';

@JsonSerializable()
@HiveType(typeId: 3)

/// This is the profile used for the current user and some basic info about them
///
/// [id] is their firebase uid and unique identifier in general
/// [name] is the name of the room (302, gym, auditorium 2, etc)
/// [building] is the location of the room (main, annex, second floor, etc)
/// [maxSize] is the largest amount of students that we can assign
/// [minSize] is the smallest amount of students we can assign
///
/// {@category Auth}
/// {@subCategory objects}
class Room extends HiveObject {
  @HiveField(0)

  /// [id] is their firebase uid and unique identifier in general
  final String id;

  @HiveField(1)

  /// [name] is the name of the room (302, gym, auditorium 2, etc)
  final String name;

  @HiveField(2)

  /// [building] is the location of the room (main, annex, second floor, etc)
  final String building;

  @HiveField(3)

  /// [maxSize] is the largest amount of students that we can assign
  final int maxSize;

  @HiveField(4)
  @JsonKey(defaultValue: 0)

  /// [minSize] is the smallest amount of students we can assign
  final int minSize;

  Room({
    required this.name,
    required this.id,
    required this.building,
    required this.maxSize,
    required this.minSize,
  });

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);

  Map<String, dynamic> toJson() => _$RoomToJson(this);
}
