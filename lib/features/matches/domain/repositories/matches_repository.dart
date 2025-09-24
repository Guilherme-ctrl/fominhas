import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/match.dart';

abstract class IMatchesRepository {
  Future<Either<Failure, List<Match>>> getAllMatches();
  Future<Either<Failure, Match>> getMatchById(String id);
  Future<Either<Failure, Match>> createMatch(Match match);
  Future<Either<Failure, Match>> updateMatch(Match match);
  Future<Either<Failure, void>> deleteMatch(String id);
}
