import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/tournament.dart';

abstract class ITournamentRepository {
  Future<Either<Failure, List<Tournament>>> getAllTournaments();
  Future<Either<Failure, Tournament?>> getTournament(String tournamentId);
  Future<Either<Failure, Tournament>> createTournament(Tournament tournament);
  Future<Either<Failure, Tournament>> updateTournament(Tournament tournament);
  Future<Either<Failure, void>> deleteTournament(String tournamentId);
  Future<Either<Failure, List<Tournament>>> getTournamentsByDate(DateTime date);
}
