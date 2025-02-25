import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'session.g.dart';

@HiveType(typeId: 6)
enum Session {
  @JsonValue('am')
  @HiveField(0)
  am,
  @JsonValue('pm')
  @HiveField(1)
  pm,
  @JsonValue('both')
  @HiveField(2)
  both,
}
