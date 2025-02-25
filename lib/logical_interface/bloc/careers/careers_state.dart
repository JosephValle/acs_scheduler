part of 'careers_bloc.dart';

@immutable
abstract class CareersState {
  final List<Career> careers;

  const CareersState({required this.careers});
}

class CareersInitial extends CareersState {
  const CareersInitial({required super.careers});
}

class CareerCreated extends CareersState {
  const CareerCreated({required super.careers});
}

class CareersLoaded extends CareersState {
  const CareersLoaded({required super.careers});
}

class CareerExistsResult extends CareersState {
  final String careerId;
  final String schoolId;
  final bool exists;

  const CareerExistsResult({
    required this.careerId,
    required this.schoolId,
    required this.exists,
    required super.careers,
  });
}

class CareerRemovedFromSchool extends CareersState {
  final String careerId;
  final String schoolId;

  const CareerRemovedFromSchool({
    required this.schoolId,
    required this.careerId,
    required super.careers,
  });
}

class CareerAddedToSchool extends CareersState {
  final Career career;
  final String schoolId;

  const CareerAddedToSchool({
    required this.career,
    required this.schoolId,
    required super.careers,
  });
}
