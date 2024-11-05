import 'package:adams_county_scheduler/network_interface/api_clients/careers_api_client.dart';
import 'package:adams_county_scheduler/network_interface/repositories/careers/base_careers_repository.dart';
import 'package:adams_county_scheduler/objects/career.dart';
import 'package:adams_county_scheduler/objects/session.dart';
import 'package:flutter/cupertino.dart';

class CareersRepository extends BaseCareersRepository {
  final CareersApiClient _apiClient = CareersApiClient();

  @override
  Future<Career> createCareer({
    required String name,
    required String category,
    required List<String> speakers,
    required String room,
    required int excelNum,
    required int maxClassSize,
    required int minClassSize,
  }) async {
    try {
      return await _apiClient.createCareer(
        name: name,
        category: category,
        speakers: speakers,
        room: room,
        excelNum: excelNum,
        maxClassSize: maxClassSize,
        minClassSize: minClassSize,
      );
    } catch (e) {
      debugPrint('create career error: $e');
      rethrow;
    }
  }

  @override
  Future<List<Career>> loadCareers() async {
    try {
      return await _apiClient.loadCareers();
    } catch (e) {
      debugPrint('Load Careers error: $e');
      return [];
    }
  }

  @override
  Future<void> addCareerToSchool({
    required String schoolId,
    required Career career,
  }) async {
    await _apiClient.addCareerToSchool(schoolId: schoolId, career: career);
  }

  @override
  Future<bool> checkCareerAddedToSchool({
    required String schoolId,
    required String careerId,
  }) async {
    return await _apiClient.checkCareerAddedToSchool(
      schoolId: schoolId,
      careerId: careerId,
    );
  }

  @override
  Future<void> removeCareerFromSchool({
    required String schoolId,
    required String careerId,
  }) async {
    await _apiClient.remoteCareerFromSchool(
      schoolId: schoolId,
      careerId: careerId,
    );
  }

  @override
  Future<void> setCareerSessionForSchool({
    required String schoolId,
    required String careerId,
    required Session session,
  }) async {
    await _apiClient.updateCareerSessionForSchool(
      schoolId: schoolId,
      careerId: careerId,
      session: session,
    );
  }

  @override
  Future<void> deleteCareer({required Career career}) async {
    await _apiClient.deleteCareer(career);
  }

  @override
  Future<void> updateCareer({required Career career}) {
    return _apiClient.updateCareer(career);
  }
}
