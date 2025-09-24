import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/services/error_handler.dart';
import '../../domain/repositories/login_repository.dart';
import '../datasource/login_datasource.dart';

class LoginRepositoryImplementation implements ILoginRepository {
  final ILoginDatasource _datasource;

  LoginRepositoryImplementation(this._datasource);

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final userCredential = await _datasource.signInWithGoogle();
      if (userCredential?.user != null) {
        return Right(userCredential!.user!);
      } else {
        final failure = AuthenticationFailure(message: 'Login cancelado pelo usuário');
        ErrorHandler.logFailure(failure, context: 'LoginRepository.signInWithGoogle');
        return Left(failure);
      }
    } on FirebaseAuthException catch (e) {
      final failure = _mapFirebaseAuthException(e);
      ErrorHandler.logFailure(failure, context: 'LoginRepository.signInWithGoogle');
      return Left(failure);
    } catch (e) {
      final failure = UnknownFailure(
        message: 'Erro inesperado durante o login',
        originalError: e,
      );
      ErrorHandler.logFailure(failure, context: 'LoginRepository.signInWithGoogle');
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, User>> signInWithApple() async {
    try {
      final userCredential = await _datasource.signInWithApple();
      if (userCredential?.user != null) {
        return Right(userCredential!.user!);
      } else {
        final failure = AuthenticationFailure(message: 'Login com Apple cancelado');
        ErrorHandler.logFailure(failure, context: 'LoginRepository.signInWithApple');
        return Left(failure);
      }
    } on FirebaseAuthException catch (e) {
      final failure = _mapFirebaseAuthException(e);
      ErrorHandler.logFailure(failure, context: 'LoginRepository.signInWithApple');
      return Left(failure);
    } catch (e) {
      final failure = UnknownFailure(
        message: 'Erro inesperado durante o login com Apple',
        originalError: e,
      );
      ErrorHandler.logFailure(failure, context: 'LoginRepository.signInWithApple');
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _datasource.signOut();
      return Right(null);
    } catch (e) {
      final failure = UnknownFailure(
        message: 'Erro ao fazer logout',
        originalError: e,
      );
      ErrorHandler.logFailure(failure, context: 'LoginRepository.signOut');
      return Left(failure);
    }
  }

  Failure _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-disabled':
        return AuthenticationFailure(message: 'Usuário desabilitado');
      case 'user-not-found':
        return AuthenticationFailure(message: 'Usuário não encontrado');
      case 'wrong-password':
        return AuthenticationFailure(message: 'Senha incorreta');
      case 'invalid-email':
        return AuthenticationFailure(message: 'Email inválido');
      case 'account-exists-with-different-credential':
        return AuthenticationFailure(
          message: 'Já existe uma conta com este email usando outro provedor',
        );
      case 'invalid-credential':
        return AuthenticationFailure(message: 'Credenciais inválidas');
      case 'operation-not-allowed':
        return AuthenticationFailure(message: 'Operação não permitida');
      case 'weak-password':
        return AuthenticationFailure(message: 'Senha muito fraca');
      case 'too-many-requests':
        return AuthenticationFailure(
          message: 'Muitas tentativas. Tente novamente mais tarde',
        );
      case 'network-request-failed':
        return NetworkFailure();
      default:
        return AuthenticationFailure(
          message: 'Erro de autenticação: ${e.message}',
        );
    }
  }
}
