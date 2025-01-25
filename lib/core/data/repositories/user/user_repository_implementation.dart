import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fominhas/core/data/datasource/user/user_datasource.dart';
import 'package:fominhas/core/domain/repositories/user/user_repository.dart';
import 'package:fominhas/core/errors/failure.dart';

class UserRepositoryImplementation implements IUserRepository {
  final IUserDatasource datasource;

  UserRepositoryImplementation(this.datasource);
  @override
  Future<Either<Failure, User?>> getGoogleUser() async {
    try {
      final result = datasource.getGoogleUser();
      return Right(result);
    } on DataPostFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(DataPostFailure());
    }
  }
}
