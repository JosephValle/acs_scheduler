import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'student_sort_state.dart';

class StudentSortCubit extends Cubit<StudentSortState> {
  int index = 0;

  bool ascending = true;

  StudentSortCubit()
      : super(const StudentSortInitial(index: 0, ascending: true));

  void sortStudents(int newIndex, bool newAscending) {
    if (index == newIndex) {
      ascending = !newAscending;
    } else {
      index = newIndex;
      ascending = true;
    }

    emit(StudentSortUpdated(ascending: ascending, index: index));
  }
}
