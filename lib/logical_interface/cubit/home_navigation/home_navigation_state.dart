part of 'home_navigation_cubit.dart';

@immutable
abstract class HomeNavigationState {
  final int selectedIndex;

  const HomeNavigationState({required this.selectedIndex});
}

class HomeNavigationInitial extends HomeNavigationState {
  const HomeNavigationInitial({required super.selectedIndex});

}

class NavigationIndexUpdated extends HomeNavigationState{
  const NavigationIndexUpdated({required super.selectedIndex});

}
