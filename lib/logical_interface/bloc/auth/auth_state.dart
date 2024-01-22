part of 'auth_bloc.dart';

@immutable
abstract class AuthState {
  final Profile? currentUser;

  const AuthState({required this.currentUser});
}

class AuthInitial extends AuthState {
  const AuthInitial({required super.currentUser});
}

class ProfileLoaded extends AuthState {
  final Profile profile;

  const ProfileLoaded({
    required this.profile,
    required super.currentUser,
  });
}

class SignInSuccess extends AuthState {
  const SignInSuccess({required super.currentUser});
}

class SignInFailed extends AuthState {
  final String message;

  const SignInFailed({required this.message, required super.currentUser});
}

class SignedOut extends AuthState {
  const SignedOut({required super.currentUser});
}
