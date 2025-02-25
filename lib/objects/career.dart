import 'package:adams_county_scheduler/objects/session.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'career.g.dart';

/// This is the object that represents a school in our system
///
/// [id] is their firebase uid and unique identifier in general
/// [name] is the long form name of the career
/// [category] is the classification of the career
/// [speakers] is a list of people that might speak on the topic
/// [session] is the session the career is available in
///
/// {@category Career}
/// {@subCategory objects}
///
@JsonSerializable()
@HiveType(typeId: 2)
class Career extends HiveObject {
  @HiveField(0)

  /// [id] is their firebase uid and unique identifier in general
  final String id;

  @HiveField(1)

  /// [name] is the long form name of the career
  final String name;

  @HiveField(2)

  /// [category] is the classification of the career
  final String category;

  @HiveField(3)

  /// [speakers] is a list of people that might speak on the topic
  final List<String> speakers;

  @HiveField(4)
  @JsonKey(defaultValue: Session.both)
  Session session;

  @HiveField(5)
  final String room;

  @HiveField(6)
  final int excelNum;

  @HiveField(7)
  final int minClassSize;

  @HiveField(8)
  final int maxClassSize;

  Career({
    required this.category,
    required this.id,
    required this.speakers,
    required this.name,
    required this.session,
    required this.room,
    required this.excelNum,
    required this.maxClassSize,
    required this.minClassSize,
  });

  factory Career.fromJson(Map<String, dynamic> json) => _$CareerFromJson(json);

  Map<String, dynamic> toJson() => _$CareerToJson(this);

  // copyWith method

  Career copyWith({
    String? id,
    String? name,
    String? category,
    List<String>? speakers,
    Session? session,
    String? room,
    int? excelNum,
    int? minClassSize,
    int? maxClassSize,
  }) {
    return Career(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      speakers: speakers ?? this.speakers,
      session: session ?? this.session,
      room: room ?? this.room,
      excelNum: excelNum ?? this.excelNum,
      minClassSize: minClassSize ?? this.minClassSize,
      maxClassSize: maxClassSize ?? this.maxClassSize,
    );
  }
}
