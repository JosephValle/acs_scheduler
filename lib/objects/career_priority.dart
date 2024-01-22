
import 'package:adams_county_scheduler/objects/career.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'career_priority.g.dart';

@JsonSerializable()
@HiveType(typeId: 5)
/// This is the profile used for the current user and some basic info about them
///
/// [firstChoice] is the [Career] id of their first choice career
/// [secondChoice] is the [Career] id of their second choice career
/// [thirdChoice] is the [Career] id of their third choice career
/// [fourthChoice] is the [Career] id of their fourth choice career
/// [fifthChoice] is the [Career] id of their fifth choice career
/// {@category SchoolPriority}
/// {@subCategory objects}
class CareerPriority extends HiveObject{

  @HiveField(0)
  @JsonKey(name: '0')
  /// [firstChoice] is the [Career] id of their first choice career

  final int firstChoice;

  @HiveField(1)
  @JsonKey(name: '1')

  /// [secondChoice] is the [Career] id of their second choice career
  final int secondChoice;

  @HiveField(2)
  @JsonKey(name: '2')

  /// [thirdChoice] is the [Career] id of their third choice career
  final int thirdChoice;

  @HiveField(3)
  @JsonKey(name: '3')

  /// [fourthChoice] is the [Career] id of their fourth choice career
  final int fourthChoice;

  @HiveField(4)
  @JsonKey(name: '4')
  /// [fifthChoice] is the [Career] id of their fifth choice career
  final int fifthChoice;



  CareerPriority({required this.fifthChoice, required this.firstChoice, required this.fourthChoice, required this.secondChoice, required this.thirdChoice});

  factory CareerPriority.fromJson(Map<String, dynamic> json) => _$CareerPriorityFromJson(json);

  Map<String, dynamic> toJson() => _$CareerPriorityToJson(this);

  List<int> preferences(){
    return [firstChoice, secondChoice, thirdChoice, fourthChoice, fifthChoice];
  }

}
