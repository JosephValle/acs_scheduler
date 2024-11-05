import 'package:firebase_auth/firebase_auth.dart';

import '../../../objects/profile.dart';

/// This repository is used to interface the auth bloc with the api clients and handle errors
///
/// {@category Bloc}
/// {@subCategory network}
abstract class BaseAuthRepository {
  ///Signs out the user
  Future<void> signOut();

  /// Get a profile by the userId returns null if it doesn't exists
  ///
  /// [userId] is the UID you want to retreive
  Future<Profile?> getProfile({required String userId});

  /// This method is used to sign into the application via google
  Future<Profile?> signIn({required String email, required String password});

  /// This getter gets the current FirebaseAuth user
  User? get currentUser;
}
