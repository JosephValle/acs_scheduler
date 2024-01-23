import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../objects/profile.dart';
import '../collection_names.dart';

/// This api client is used for interfacing with the firebase auth sdk and managing the current user sessions
///
/// {@category Auth}
/// {@subCategory network}
class AuthApiClient {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  ///This will signout the firebase auth user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// This will return a profile for a userId if that profile exists
  ///
  /// [userId] is the Firebase UID for a specific user
  Future<Profile?> getProfile({required String userId}) async {
    try {
      return Profile.fromJson(
        (await _firestore.collection(usersCollection).doc(userId).get())
                .data() ??
            {},
      );
    } catch (e) {
      debugPrint('failed to get user $userId: $e');
      return null;
    }
  }

  /// This method will trigger the google sign in method. This will display the proper native items to have a user login and redirect accordingly
  Future<Profile?> signIn() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn(
      clientId: kDebugMode
          ? '215002605660-k33su7pe60atmvmf3iv97mcggbb4p3vq.apps.googleusercontent.com'
          : '215002605660-d2fjkhsnbbgijvjg7lst9k60cs61f6lm.apps.googleusercontent.com',
    ).signIn(); //todo must add the hostdomain for the clients

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    Profile? profile;
    if (userCredential.user != null) {
      profile = await getProfile(userId: userCredential.user!.uid);

      if (profile == null) {
        await _firestore
            .collection(usersCollection)
            .doc(userCredential.user!.uid)
            .set({
          'id': userCredential.user!.uid,
          'email': userCredential.user!.email,
          'displayName': userCredential.user!.displayName,
          'imageUrl': userCredential.user!.photoURL,
        });

        profile = Profile(
          email: userCredential.user!.email!,
          id: userCredential.user!.uid,
          isAdmin: false,
          imageUrl: userCredential.user!.photoURL ?? '',
          displayName: userCredential.user!.displayName ?? '',
        );
      }
    }
    return profile;
  }

  ///This getter can be used to find the current Firebase auth user
  User? get currentUser => _auth.currentUser;
}
