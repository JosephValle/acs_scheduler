import 'package:adams_county_scheduler/objects/career.dart';

import '../../../objects/room.dart';

abstract class BaseSchoolDetailRepository {
  ///Load the careers associated with a school
  ///
  /// [schoolId] is the id of the school we are loading for
  Future<List<Career>> loadCareers({required String schoolId});

  ///Load the rooms associated with a school
  ///
  /// [schoolId] is the id of the school we are loading for
  Future<List<Room>> loadRooms({required String schoolId});

  /// This method can be used to create a room
  ///
  /// [schoolId] is the id of the [School] this [Room] belongs to
  /// [name] is the name of the room
  /// [building] is the building this room is in
  /// [maxSize] is the max amount of students that can be assigned at once
  /// [minSize] is the minimum amount of students that can be in the room, can be 0
  Future<Room> createRoom({
    required String schoolId,
    required String name,
    required String building,
    required int maxSize,
    required int? minSize,
  });
}
