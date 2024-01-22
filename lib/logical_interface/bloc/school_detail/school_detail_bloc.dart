import 'package:adams_county_scheduler/network_interface/repositories/school_detail/school_detail_repository.dart';
import 'package:adams_county_scheduler/network_interface/repositories/students/students_repository.dart';
import 'package:adams_county_scheduler/objects/room.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../objects/career.dart';
import '../../../objects/student.dart';

part 'school_detail_event.dart';

part 'school_detail_state.dart';

/// This bloc controls the details of a single school at a time.
///
/// [students] is the list of students currently being viewed
/// [rooms] is the rooms of the school currently being viewed
/// [careers] is the list of careers currently active for this school
class SchoolDetailBloc extends Bloc<SchoolDetailEvent, SchoolDetailState> {
  List<Student> students = [];
  List<Room> rooms = [];
  List<Career> careers = [];

  final SchoolDetailRepository _schoolDetailRepository;
  final StudentsRepository _studentsRepository;

  /// This is the default constrctor for the [SchoolDetailBloc]
  ///
  /// [schoolDetailRepository] is the repo we will use in this bloc.
  /// [_studentsRepository] is the repo used to interface with students
  SchoolDetailBloc({
    required SchoolDetailRepository schoolDetailRepository,
    required StudentsRepository studentsRepository,
  })  : _schoolDetailRepository = schoolDetailRepository,
        _studentsRepository = studentsRepository,
        super(const SchoolDetailInitial(
            students: [], rooms: [], careers: [], schoolId: '',),) {
    on<LoadSchoolDetails>(_mapLoadSchoolDetailsToState);
    on<RemoveCareer>(_mapRemoveCareerFromSchoolToState);
    on<AddCareer>(_mapAddCareerToSchoolToState);
    on<AddRoom>(_mapAddRoomToState);
    on<AddStudent>(_mapAddStudentToState);
  }

  void _mapAddStudentToState(AddStudent event, emit) {
    students.add(event.student);

    students.sort((a, b) => ('${a.lastName}, ${a.firstName}')
        .compareTo(('${b.lastName}, ${b.firstName}')),);
    emit(SchoolInformationLoaded(
        careers: careers,
        rooms: rooms,
        students: students,
        schoolId: event.schoolId,),);
  }

  void _mapAddRoomToState(AddRoom event, emit) async {
    Room room = await _schoolDetailRepository.createRoom(
        schoolId: event.schoolId,
        name: event.name,
        building: event.building,
        maxSize: event.maxSize,
        minSize: event.minSize,);

    rooms.add(room);
    emit(SchoolRoomsAdded(
        careers: careers,
        rooms: rooms,
        students: students,
        schoolId: event.schoolId,),);
  }

  void _mapLoadSchoolDetailsToState(LoadSchoolDetails event, emit) async {
    emit(SchoolInformationLoading(
        careers: careers,
        rooms: rooms,
        students: students,
        schoolId: event.schoolId,),);
    careers =
        await _schoolDetailRepository.loadCareers(schoolId: event.schoolId);
    rooms = await _schoolDetailRepository.loadRooms(schoolId: event.schoolId);
    students =
        await _studentsRepository.getStudentBySchool(schoolId: event.schoolId);

    students.sort((a, b) => ('${a.lastName}, ${a.firstName}')
        .compareTo(('${b.lastName}, ${b.firstName}')),);
    rooms.sort((a, b) => a.name.compareTo(b.name));
    careers.sort((a, b) => a.name.compareTo(b.name));
    emit(SchoolInformationLoaded(
        careers: careers,
        rooms: rooms,
        students: students,
        schoolId: event.schoolId,),);
  }

  void _mapAddCareerToSchoolToState(AddCareer event, emit) async {
    careers.add(event.career);

    careers.sort((a, b) => a.name.compareTo(b.name));
    emit(SchoolInformationLoaded(
        careers: careers,
        rooms: rooms,
        students: students,
        schoolId: event.schoolId,),);
  }

  void _mapRemoveCareerFromSchoolToState(RemoveCareer event, emit) async {
    if (careers.any((element) => element.id == event.careerId)) {
      careers.removeWhere((element) => element.id == event.careerId);
    }

    careers.sort((a, b) => a.name.compareTo(b.name));

    emit(SchoolInformationLoaded(
        careers: careers,
        rooms: rooms,
        students: students,
        schoolId: event.schoolId,),);
  }
}
