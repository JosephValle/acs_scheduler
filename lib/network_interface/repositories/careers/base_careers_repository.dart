import '../../../objects/career.dart';
import '../../../objects/session.dart';

abstract class BaseCareersRepository {
  /// This method can be used to create a new career for the system
  ///
  /// [name] is the name of the career
  /// [category] is the category of the career business, tech, etc.
  /// [speakers] is a list of people that might present on the career
  Future<Career> createCareer({
    required String name,
    required String category,
    required List<String> speakers,
    required String room,
    required int excelNum,
    required int maxClassSize,
    required int minClassSize,
  });

  ///Returns a list of all careers entered
  Future<List<Career>> loadCareers();

  ///Check if a career is active for a school
  Future<bool> checkCareerAddedToSchool({
    required String schoolId,
    required String careerId,
  });

  ///Adds a career to a school
  ///
  /// [schoolId] is the id of the school to add to
  /// [career] is the career we want to add
  Future<void> addCareerToSchool({
    required String schoolId,
    required Career career,
  });

  ///Removes a career from a school
  ///
  /// [schoolId] is the id of the school to add to
  /// [career] is the career we want to add
  Future<void> removeCareerFromSchool({
    required String schoolId,
    required String careerId,
  });

  ///Sets the session for a career for a school
  ///
  /// [session] is the [Session] that a career is available at this school
  /// [schoolId] is the school this career session is set for
  /// [careerId] is the id of the career this session applies for
  Future<void> setCareerSessionForSchool({
    required String schoolId,
    required String careerId,
    required Session session,
  });

  /// Deletes a career for
  ///
  /// [career] is the [career] to be deleted
  Future<void> deleteCareer({required Career career});

  /// Updates a career
  ///
  /// [career] is the career to be updated
  Future<void> updateCareer({required Career career});
}
