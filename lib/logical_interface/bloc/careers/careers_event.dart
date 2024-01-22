part of 'careers_bloc.dart';

@immutable
abstract class CareersEvent {}

/// This will create a career for the system
///
/// [name] is the name of the career
/// [category] is the category the career should be under
/// [speakers] is a list of the people that may speak at the career day
class CreateCareer extends CareersEvent {
  final String name;
  final String category;
  final String room;
  final int excelNum;
  final int minClassSize;
  final int maxClassSize;
  final List<String> speakers;

  CreateCareer({
    required this.speakers,
    required this.category,
    required this.name,
    required this.room,
    required this.excelNum,
    required this.minClassSize,
    required this.maxClassSize,
  });
}

///This will load all of the careers available
class LoadCareers extends CareersEvent {}

/// This will notify us if a career exists for a school
///
/// [schoolId] is the school we are checking against
/// [careerId] is the career we are checking against
class CheckCareerExistsForSchool extends CareersEvent {
  final String schoolId;
  final String careerId;

  CheckCareerExistsForSchool({required this.careerId, required this.schoolId});
}

/// This will add a career to a school
///
/// [schoolId] is the school we are adding to
/// [career] is the career we are adding
class AddCareerToSchool extends CareersEvent {
  final Career career;
  final String schoolId;

  AddCareerToSchool({required this.schoolId, required this.career});
}

/// This will remove a career from a school
///
/// [schoolId] is the school we are removing from
/// [careerId] is the career we want to remove

class RemoveCareerFromSchool extends CareersEvent {
  final String schoolId;
  final String careerId;

  RemoveCareerFromSchool({required this.schoolId, required this.careerId});
}

/// This will delete a career
///
/// [career] is the career to be deleted

class DeleteCareer extends CareersEvent {
  final Career career;

  DeleteCareer({
    required this.career,
  });
}

///This is used to set the session of which a career is available at a specific school
///
/// [session] is the [Session] that a career is available at this school
/// [schoolId] is the school this career session is set for
/// [careerId] is the id of the career this session applies for
class SetCareerSessionForSchool extends CareersEvent {
  final Session session;
  final String schoolId;
  final String careerId;

  SetCareerSessionForSchool({
    required this.careerId,
    required this.schoolId,
    required this.session,
  });
}
