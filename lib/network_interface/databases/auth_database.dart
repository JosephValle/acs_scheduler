import 'package:hive/hive.dart';

import '../../objects/profile.dart';

/// This database will store some basic user info on it about the current user that we can use as initial values
///
/// {@category Auth}
/// {@subCategory logic}
class AuthDatabase {
  late Box hiveBox;

  AuthDatabase._init(Box box) {
    hiveBox = box;
  }

  ///init function for adapters that initializes the hive box
  static Future<AuthDatabase> init() async {
    late Box hiveBox;
    try {
      hiveBox = await Hive.openBox('authBox');
    } catch (e) {
      await Hive.deleteBoxFromDisk('authBox');
      hiveBox = await Hive.openBox('authBox');
    }
    return AuthDatabase._init(hiveBox);
  }

  ///This method is used to add a user into the auth database. It also removes the other user's to only store the current user
  ///
  /// user: instance of user that is to be stored as the current user and stored at index 0
  Future<void> addUser(Profile user) async {
    await hiveBox.clear();
    await hiveBox.add(user);
  }

  ///This method is used to clear the current user, for example on logout
  Future<void> clearUser() async {
    await hiveBox.clear();
  }

  ///This method is used to get the current user from the database
  ///
  /// If there is a user the User is returned, otherwise a null value is returned(i.e. logged out state)
  Profile? getCurrentUser() {
    try {
      return hiveBox.getAt(0);
    } catch (e) {
      return null;
    }
  }

  Future<void> close() async {
    await hiveBox.close();
  }
}
