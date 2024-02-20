import 'package:adams_county_scheduler/objects/school.dart';
import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';

import '../../../network_interface/repositories/schools/schools_repository.dart';

part 'schools_event.dart';

part 'schools_state.dart';

class SchoolsBloc extends Bloc<SchoolsEvent, SchoolsState> {
  final SchoolsRepository _schoolsRepository;

  List<School> schools = [];

  SchoolsBloc({required SchoolsRepository schoolsRepository})
      : _schoolsRepository = schoolsRepository,
        super(const SchoolsInitial(schools: [])) {
    on<CreateSchool>(_mapCreateSchoolToState);
    on<UploadSchool>(_mapUploadSchoolToState);
    on<UploadProgressUpdated>(_mapUploadProgressUpdatedToState);
    on<LoadSchools>(_mapLoadSchoolsToState);
    on<DeleteSchool>(_deleteSchool);
  }

  void _mapLoadSchoolsToState(LoadSchools event, emit) async {
    schools = await _schoolsRepository.loadSchools();

    emit(SchoolsLoaded(schools: schools));
  }

  void _mapCreateSchoolToState(CreateSchool event, emit) async {
    if (event.image != null) {
      await _schoolsRepository.uploadSchoolImage(
        schoolShortName: event.schoolShortName,
        image: event.image!,
        onFinished: (String url) async {
          add(
            UploadSchool(
              time: event.time,
              imageUrl: url,
              schoolShortName: event.schoolShortName,
              schoolName: event.schoolName,
              category: event.category,
            ),
          );
        },
        onProgress: (double progress) {
          add(UploadProgressUpdated(progress: progress));
          if (progress >= 100) {}
        },
      );
    } else {
      add(
        UploadSchool(
          time: event.time,
          imageUrl: null,
          schoolShortName: event.schoolShortName,
          schoolName: event.schoolName,
          category: event.category,
        ),
      );
    }
  }

  void _mapUploadProgressUpdatedToState(
      UploadProgressUpdated event,
      emit,
      ) async {
    emit(
      ImageUploadProgressUpdated(schools: schools, progress: event.progress),
    );
  }

  void _mapUploadSchoolToState(UploadSchool event, emit) async {
    School newSchool = await _schoolsRepository.createSchool(
      schoolName: event.schoolName,
      schoolShortName: event.schoolShortName,
      category: event.category,
      imageUrl: event.imageUrl,
      time: event.time,
    );

    schools.add(newSchool);
    emit(SchoolCreated(schools: schools));
  }

  void _deleteSchool(DeleteSchool event, emit) async {
    // TODO: ACTUALLY DELETE IT
    schools.removeWhere((element) => element.id == event.school.id);
    emit(SchoolsLoaded(schools: schools));
  }
}
