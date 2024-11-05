part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

/// This will get a profile in the auth bloc
class GetProfile extends AuthEvent {
  final String userId;

  /// This will get a profile in the auth bloc
  ///
  /// [userId] is the value of the user we want to retrieve
  GetProfile({required this.userId});
}

///This event sends the signal to start the sign in process
class SignIn extends AuthEvent {
  final String email;
  final String password;

  SignIn({required this.email, required this.password});
}

///This event sends the signal to sign the user out
class SignOut extends AuthEvent {}
