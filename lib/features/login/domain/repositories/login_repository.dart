import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/failure.dart';

abstract class ILoginRepository {
  Future<Either<Failure, UserCredential?>> loginGoogle();
  Future<Either<Failure, UserCredential?>> loginApple();
}
