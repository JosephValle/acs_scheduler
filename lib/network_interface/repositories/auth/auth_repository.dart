import 'package:adams_county_scheduler/network_interface/api_clients/auth_api_client.dart';
import 'package:adams_county_scheduler/network_interface/repositories/auth/base_auth_repository.dart';
import 'package:adams_county_scheduler/objects/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

/// This is the implimentation of [BaseAuthRepository]
///
///
/// {@category Auth}
/// {@subCategory network}
class AuthRepository implements BaseAuthRepository {
  final AuthApiClient _authApiClient = AuthApiClient();

  @override
  User? get currentUser => _authApiClient.currentUser;

  @override
  Future<Profile?> getProfile({required String userId}) async {
    try {
      return await _authApiClient.getProfile(userId: userId);
    } catch (e) {
      debugPrint('get profile error $e');
      return null;
    }
  }

  @override
  Future<Profile?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _authApiClient.signIn(email: email, password: password);
    } catch (e) {
      debugPrint('sign in error $e');
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _authApiClient.signOut();
    } catch (e) {
      debugPrint('sign out error $e');
    }
  }
}
