import 'package:firebase_auth/firebase_auth.dart';
import 'package:fominhas/core/data/datasource/user/user_datasource.dart';

class UserDatasourceInplementation implements IUserDatasource {
  @override
  User? getGoogleUser() {
    try {
      return FirebaseAuth.instance.currentUser;
    } catch (e) {
      throw Exception('Failed to load data');
    }
  }
}
