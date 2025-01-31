import 'package:firebase_auth/firebase_auth.dart';

abstract class ILoginDatasource {
  Future<UserCredential?> loginGoogle();
  Future<UserCredential?> loginApple();
}
