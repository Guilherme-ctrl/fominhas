import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/failure.dart';

abstract class ILoginRepository {
  Future<Either<Failure, User>> signInWithGoogle();
  Future<Either<Failure, User>> signInWithApple();
  Future<Either<Failure, void>> signOut();
}
