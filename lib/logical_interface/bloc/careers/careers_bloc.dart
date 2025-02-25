import 'package:adams_county_scheduler/network_interface/repositories/careers/careers_repository.dart';
import 'package:adams_county_scheduler/objects/session.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../objects/career.dart';

part 'careers_event.dart';

part 'careers_state.dart';

class CareersBloc extends Bloc<CareersEvent, CareersState> {
  final CareersRepository _careersRepository;

  List<Career> careers = [];

  CareersBloc({required CareersRepository careersRepository})
      : _careersRepository = careersRepository,
        super(const CareersInitial(careers: [])) {
    on<CreateCareer>(_mapCreateCareerToState);
    on<LoadCareers>(_mapLoadCareersToState);
    on<CheckCareerExistsForSchool>(_mapCheckCareerExistsForSchoolToState);
    on<AddCareerToSchool>(_mapAddCareerToSchoolToState);
    on<RemoveCareerFromSchool>(_mapRemoveCareerFromSchoolToState);
    on<SetCareerSessionForSchool>(_mapSetCareerSessionForSchoolToState);
    on<DeleteCareer>(_deleteCareer);
    on<UpdateCareer>(_updateCareer);
  }

  Future<void> _mapSetCareerSessionForSchoolToState(
    SetCareerSessionForSchool event,
    emit,
  ) async {
    await _careersRepository.setCareerSessionForSchool(
      schoolId: event.schoolId,
      careerId: event.careerId,
      session: event.session,
    );

    for (final Career career
        in careers.where((element) => element.id == event.careerId)) {
      career.session = event.session;
    }

    careers.sort((a, b) => a.name.compareTo(b.name));
    emit(CareersLoaded(careers: careers));
  }

  Future<void> _mapCreateCareerToState(CreateCareer event, emit) async {
    final Career career = await _careersRepository.createCareer(
      name: event.name,
      category: event.category,
      speakers: event.speakers,
      room: event.room,
      excelNum: event.excelNum,
      maxClassSize: event.maxClassSize,
      minClassSize: event.minClassSize,
    );

    careers.add(career);

    careers.sort((a, b) => a.name.compareTo(b.name));

    emit(CareerCreated(careers: careers));
  }

  Future<void> _mapLoadCareersToState(LoadCareers event, emit) async {
    careers = await _careersRepository.loadCareers();

    careers.sort((a, b) => a.name.compareTo(b.name));
    emit(CareersLoaded(careers: careers));
  }

  Future<void> _mapCheckCareerExistsForSchoolToState(
    CheckCareerExistsForSchool event,
    emit,
  ) async {
    final bool exists = await _careersRepository.checkCareerAddedToSchool(
      schoolId: event.schoolId,
      careerId: event.careerId,
    );

    emit(
      CareerExistsResult(
        careerId: event.careerId,
        schoolId: event.schoolId,
        exists: exists,
        careers: careers,
      ),
    );
  }

  Future<void> _mapAddCareerToSchoolToState(
    AddCareerToSchool event,
    emit,
  ) async {
    await _careersRepository.addCareerToSchool(
      schoolId: event.schoolId,
      career: event.career,
    );
    emit(
      CareerAddedToSchool(
        career: event.career,
        schoolId: event.schoolId,
        careers: careers,
      ),
    );
  }

  Future<void> _mapRemoveCareerFromSchoolToState(
    RemoveCareerFromSchool event,
    emit,
  ) async {
    await _careersRepository.removeCareerFromSchool(
      schoolId: event.schoolId,
      careerId: event.careerId,
    );
    emit(
      CareerRemovedFromSchool(
        schoolId: event.schoolId,
        careerId: event.careerId,
        careers: careers,
      ),
    );
  }

  Future<void> _deleteCareer(
    DeleteCareer event,
    emit,
  ) async {
    await _careersRepository.deleteCareer(career: event.career);
    careers.removeWhere((element) => element.id == event.career.id);
    emit(CareersLoaded(careers: careers));
  }

  Future<void> _updateCareer(
    UpdateCareer event,
    emit,
  ) async {
    await _careersRepository.updateCareer(career: event.career);
    careers.removeWhere((element) => element.id == event.career.id);
    careers.add(event.career);
    careers.sort((a, b) => a.name.compareTo(b.name));
    emit(CareerCreated(careers: careers));
  }
}
