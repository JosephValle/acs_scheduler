import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'time_session.g.dart';

@JsonSerializable()
@HiveType(typeId: 6)
class TimeSession extends HiveObject {
  @HiveField(0)
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final Timestamp time;

  @HiveField(1)
  final String id;

  @HiveField(2)
  final String session;

  TimeSession({
    required this.time,
    required this.id,
    required this.session,
  });

  factory TimeSession.fromJson(Map<String, dynamic> json) =>
      _$TimeSessionFromJson(json);

  Map<String, dynamic> toJson() => _$TimeSessionToJson(this);

  // Adjusted methods
  static Timestamp _timestampFromJson(Timestamp json) => json;

  static Timestamp _timestampToJson(Timestamp timestamp) => timestamp;
}
