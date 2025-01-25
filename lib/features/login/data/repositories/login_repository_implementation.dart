import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fominhas/core/errors/failure.dart';
import 'package:fominhas/features/login/data/datasource/login_datasource.dart';
import 'package:fominhas/features/login/domain/repositories/login_repository.dart';

class LoginRepositoryImplementation implements ILoginRepository {
  final ILoginDatasource datasource;

  LoginRepositoryImplementation(this.datasource);

  @override
  Future<Either<Failure, UserCredential?>> loginGoogle() async {
    try {
      final result = await datasource.loginGoogle();
      return Right(result);
    } on DataPostFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(DataPostFailure());
    }
  }
}
