import 'package:adams_county_scheduler/network_interface/repositories/auth/auth_repository.dart';
import 'package:adams_county_scheduler/objects/profile.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';

part 'auth_state.dart';

///This bloc controls the primary functions of the application for authentication and will also handle current user events.
///
/// {@category Auth}
/// {@subCategory logic}
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  ///[_authRepository] is the repo the will be used by this bloc to control the user states
  final AuthRepository _authRepository;

  ///[currentUser] is the user currently using the app. Null if not logged in
  Profile? currentUser;

  /// This is the default constructor
  ///
  /// [authRepository] should be passed to initialize the repo of the bloc
  AuthBloc({required AuthRepository authRepository, User? currentUser})
      : _authRepository = authRepository,
        super(const AuthInitial(currentUser: null)) {
    on<GetProfile>(_mapGetProfileToState);
    on<SignIn>(_mapSignInToState);
    on<SignOut>(_mapSignOutToState);
    if (currentUser != null) {
      add(GetProfile(userId: currentUser.uid));
    }
  }

  Future<void> _mapSignOutToState(SignOut event, emit) async {
    await _authRepository.signOut();
    currentUser = null;

    emit(SignedOut(currentUser: currentUser));
  }

  Future<void> _mapSignInToState(SignIn event, emit) async {
    final Profile? user = await _authRepository.signIn(
      email: event.email,
      password: event.password,
    );
    if (user != null) {
      currentUser = user;
      emit(SignInSuccess(currentUser: currentUser));
    } else {
      emit(
        SignInFailed(
          message:
              'Sorry, we had some trouble logging you in. Please try again.',
          currentUser: currentUser,
        ),
      );
    }
  }

  Future<void> _mapGetProfileToState(GetProfile event, emit) async {
    final Profile? profile =
        await _authRepository.getProfile(userId: event.userId);

    if (profile != null) {
      if (profile.id == _authRepository.currentUser?.uid) {
        currentUser = profile;
      }

      emit(ProfileLoaded(profile: profile, currentUser: currentUser));
    }
  }
}
