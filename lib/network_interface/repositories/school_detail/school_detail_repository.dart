import 'package:adams_county_scheduler/network_interface/api_clients/school_detail_api_client.dart';
import 'package:adams_county_scheduler/network_interface/repositories/school_detail/base_school_detail_repository.dart';
import 'package:adams_county_scheduler/objects/career.dart';
import 'package:adams_county_scheduler/objects/room.dart';
import 'package:flutter/cupertino.dart';

class SchoolDetailRepository implements BaseSchoolDetailRepository {
  final SchoolDetailsApiClient _schoolDetailsApiClient =
      SchoolDetailsApiClient();

  @override
  Future<List<Career>> loadCareers({required String schoolId}) async {
    try {
      return await _schoolDetailsApiClient.loadCareers(schoolId: schoolId);
    } catch (e) {
      debugPrint('load careers error: e');
      return [];
    }
  }

  @override
  Future<Room> createRoom(
      {required String schoolId,
      required String name,
      required String building,
      required int maxSize,
      required int? minSize,}) async {
    return await _schoolDetailsApiClient.createRoom(
        schoolId: schoolId,
        name: name,
        building: building,
        maxSize: maxSize,
        minSize: minSize,);
  }

  @override
  Future<List<Room>> loadRooms({required String schoolId})async {
    try{
      return await _schoolDetailsApiClient.loadRooms(schoolId: schoolId);
    }catch(e){
      debugPrint('Load rooms error $e');
      return [];
    }
  }
}
