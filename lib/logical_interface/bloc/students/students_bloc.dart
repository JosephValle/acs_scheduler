import 'package:adams_county_scheduler/network_interface/repositories/students/students_repository.dart';
import 'package:adams_county_scheduler/objects/career_priority.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_excel/excel.dart';
import 'package:meta/meta.dart';

import '../../../objects/student.dart';

part 'students_event.dart';

part 'students_state.dart';

class StudentsBloc extends Bloc<StudentsEvent, StudentsState> {
  final StudentsRepository _studentsRepository;

  final List<String> cells = [
    'first name',
    'last name',
    'school',
    '1 priority',
    '2 priority',
    '3 priority',
    '4 priority',
    '5 priority',
  ];

  List<Student> students = [];

  StudentsBloc({required StudentsRepository studentsRepository})
      : _studentsRepository = studentsRepository,
        super(const StudentsInitial(students: [])) {
    on<CreateStudent>(_mapCreateStudentToState);
    on<LoadStudents>(_mapLostStudentsToState);
    on<SortStudents>(_mapSortStudentsToState);
    on<BulkUploadStudents>(_mapBulkUploadStudentsToState);
    on<ClearAllStudents>(_clearAllStudents);
  }

  void _mapBulkUploadStudentsToState(BulkUploadStudents event, emit) async {
    emit(BulkUploadStarted(students: students));
    List<String> errors = [];
    List<Data?> headers = event.sheet.row(0);

    List<String> headerValues = headers
        .map<String>((e) => e?.value.toString().toLowerCase() ?? '')
        .toList();

    List<int> indexes = [];

    for (var cell in cells) {
      indexes.add(headerValues.indexOf(cell));
    }

    Map<String, String> schoolsMapping = {};

    for (var data in event.sheet.rows.sublist(1)) {
      String firstName = data[indexes[0]]!.value.toString();

      String lastName = data[indexes[1]]!.value.toString();

      String school = data[indexes[2]]!.value.toString();

      String firstChoice = data[indexes[3]]!.value.toString();

      String secondChoice = data[indexes[4]]!.value.toString();

      String thirdChoice = data[indexes[5]]!.value.toString();

      String fourthChoice = data[indexes[6]]!.value.toString();

      String fifthChoice = data[indexes[7]]!.value.toString();

      String? schoolIdFromMap = schoolsMapping[school];

      String? schoolId = schoolIdFromMap ??
          await _studentsRepository.getSchoolIdByName(schoolName: school);

      if (schoolId != null) {
        if (schoolIdFromMap == null) {
          schoolsMapping[school] = schoolId;
        }

        Student student = await _studentsRepository.createStudent(
          firstName: firstName,
          lastName: lastName,
          careerPriority: CareerPriority(
            fifthChoice: int.parse(fifthChoice),
            firstChoice: int.parse(firstChoice),
            fourthChoice: int.parse(fourthChoice),
            secondChoice: int.parse(secondChoice),
            thirdChoice: int.parse(thirdChoice),
          ),
          school: school,
          schoolId: schoolId,
          grade: -1,
        );

        students.add(student);
      } else {
        errors.add('$lastName, $firstName');
      }
    }

    students.sort(
      (a, b) => ('${a.lastName}, ${a.firstName}')
          .compareTo(('${b.lastName}, ${b.firstName}')),
    );
    emit(UploadFinished(errors: errors, students: students));
  }

  void _mapLostStudentsToState(LoadStudents event, emit) async {
    students = await _studentsRepository.getStudents();

    students.sort(
      (a, b) => ('${a.lastName}, ${a.firstName}')
          .compareTo(('${b.lastName}, ${b.firstName}')),
    );

    emit(StudentsLoaded(students: students));
  }

  void _mapCreateStudentToState(CreateStudent event, emit) async {
    Student student = await _studentsRepository.createStudent(
      firstName: event.firstName,
      lastName: event.lastName,
      careerPriority: event.priority,
      school: event.schoolName,
      schoolId: event.schoolId,
      grade: event.grade,
    );

    students.add(student);

    students.sort(
      (a, b) => ('${a.lastName}, ${a.firstName}')
          .compareTo(('${b.lastName}, ${b.firstName}')),
    );

    emit(StudentCreated(student: student, students: students));
  }

  void _clearAllStudents(ClearAllStudents event, emit) async {

    await _studentsRepository.clearAllStudents();

    students = [];
    emit(StudentsLoaded(students: students));
  }

  void _mapSortStudentsToState(SortStudents event, emit) async {
    switch (event.index) {
      case 0:
        {
          event.ascending
              ? students.sort((a, b) => a.firstName.compareTo(b.firstName))
              : students.sort((b, a) => a.firstName.compareTo(b.firstName));
        }
      case 1:
        {
          event.ascending
              ? students.sort((a, b) => a.lastName.compareTo(b.lastName))
              : students.sort((b, a) => a.lastName.compareTo(b.lastName));
        }
      case 2:
        {
          event.ascending
              ? students.sort((a, b) => a.school.compareTo(b.school))
              : students.sort((b, a) => a.school.compareTo(b.school));
        }
      case 3:
        {
          event.ascending
              ? students.sort(
                  (a, b) => a.careerPriority.firstChoice
                      .compareTo(b.careerPriority.firstChoice),
                )
              : students.sort(
                  (b, a) => a.careerPriority.firstChoice
                      .compareTo(b.careerPriority.firstChoice),
                );
        }
      case 4:
        {
          event.ascending
              ? students.sort(
                  (a, b) => a.careerPriority.secondChoice
                      .compareTo(b.careerPriority.secondChoice),
                )
              : students.sort(
                  (b, a) => a.careerPriority.secondChoice
                      .compareTo(b.careerPriority.secondChoice),
                );
        }
      case 5:
        {
          event.ascending
              ? students.sort(
                  (a, b) => a.careerPriority.thirdChoice
                      .compareTo(b.careerPriority.thirdChoice),
                )
              : students.sort(
                  (b, a) => a.careerPriority.thirdChoice
                      .compareTo(b.careerPriority.thirdChoice),
                );
        }
      case 6:
        {
          event.ascending
              ? students.sort(
                  (a, b) => a.careerPriority.fourthChoice
                      .compareTo(b.careerPriority.fourthChoice),
                )
              : students.sort(
                  (b, a) => a.careerPriority.fourthChoice
                      .compareTo(b.careerPriority.fourthChoice),
                );
        }
      case 7:
        {
          event.ascending
              ? students.sort(
                  (a, b) => a.careerPriority.fifthChoice
                      .compareTo(b.careerPriority.fifthChoice),
                )
              : students.sort(
                  (b, a) => a.careerPriority.fifthChoice
                      .compareTo(b.careerPriority.fifthChoice),
                );
        }
    }

    emit(StudentsLoaded(students: students));
  }
}
