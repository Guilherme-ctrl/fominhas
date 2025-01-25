import 'package:firebase_auth/firebase_auth.dart';
import 'package:fominhas/features/login/data/datasource/login_datasource.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginDatasourceImplementation implements ILoginDatasource {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  LoginDatasourceImplementation();

  @override
  Future<UserCredential?> loginGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Autentica no Firebase com as credenciais do Google
        final response = await _auth.signInWithCredential(credential);
        //dio.interceptors.add(BasicInterceptor(model.email, token, tokenVaultNext));

        // Navega para a tela inicial após o login
        return response;
      }
    } catch (e) {
      throw Exception('Failed to load data');
    }
    return null;
  }
}
