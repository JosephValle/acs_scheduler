import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'profile.g.dart';

@JsonSerializable()
@HiveType(typeId: 0)

/// This is the profile used for the current user and some basic info about them
///
/// [id] is their firebase uid and unique identifier in general
/// [email] is the user's email associated with their account
/// [isAdmin] indicates if they are a super user
/// [displayName] is the user's visible name
/// [imageUrl] is the user's profile image
///
/// {@category Auth}
/// {@subCategory objects}
class Profile extends HiveObject {
  @HiveField(0)

  /// [id] is their firebase uid and unique identifier in general
  final String id;

  @HiveField(1)
  @JsonKey(defaultValue: '')

  /// [email] is the user's email associated with their account
  final String email;

  @HiveField(2)
  @JsonKey(defaultValue: false)

  /// [isAdmin] indicates if they are a super user
  final bool isAdmin;

  @HiveField(3)
  @JsonKey(defaultValue: '')

  /// [displayName] is the user's visible name
  final String displayName;

  @HiveField(4)
  @JsonKey(defaultValue: '')

  /// [imageUrl] is the user's profile image
  final String imageUrl;

  Profile({
    required this.email,
    required this.id,
    required this.isAdmin,
    required this.displayName,
    required this.imageUrl,
  });

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}
