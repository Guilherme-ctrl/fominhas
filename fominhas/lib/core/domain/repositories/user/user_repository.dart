import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fominhas/core/errors/failure.dart';

abstract class IUserRepository {
  Future<Either<Failure, User?>> getGoogleUser();
}
