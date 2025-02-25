import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'home_navigation_state.dart';

class HomeNavigationCubit extends Cubit<HomeNavigationState> {
  int selectedIndex = 0;
  HomeNavigationCubit() : super(const HomeNavigationInitial(selectedIndex: 0));

  void updateIndex({required int index}) {
    selectedIndex = index;

    emit(NavigationIndexUpdated(selectedIndex: selectedIndex));
  }
}
