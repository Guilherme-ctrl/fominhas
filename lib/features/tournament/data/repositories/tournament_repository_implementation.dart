import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/services/error_handler.dart';
import '../../domain/entities/tournament.dart';
import '../../domain/repositories/tournament_repository.dart';
import '../datasource/tournament_datasource.dart';

class TournamentRepositoryImplementation implements ITournamentRepository {
  final ITournamentDatasource _datasource;

  TournamentRepositoryImplementation(this._datasource);


  @override
  Future<Either<Failure, List<Tournament>>> getAllTournaments() async {
    try {
      final tournaments = await _datasource.getAllTournaments();
      return Right(tournaments);
    } on Failure catch (failure) {
      ErrorHandler.logFailure(failure, context: 'TournamentRepository.getAllTournaments');
      return Left(failure);
    } catch (e) {
      final failure = UnknownFailure(message: 'Erro ao carregar torneios', originalError: e);
      ErrorHandler.logFailure(failure, context: 'TournamentRepository.getAllTournaments');
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, Tournament?>> getTournament(String tournamentId) async {
    try {
      final tournament = await _datasource.getTournament(tournamentId);
      return Right(tournament);
    } on Failure catch (failure) {
      ErrorHandler.logFailure(failure, context: 'TournamentRepository.getTournament');
      return Left(failure);
    } catch (e) {
      final failure = UnknownFailure(message: 'Erro ao buscar torneio', originalError: e);
      ErrorHandler.logFailure(failure, context: 'TournamentRepository.getTournament');
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, Tournament>> createTournament(Tournament tournament) async {
    try {
      final created = await _datasource.createTournament(tournament);
      return Right(created);
    } on Failure catch (failure) {
      ErrorHandler.logFailure(failure, context: 'TournamentRepository.createTournament');
      return Left(failure);
    } catch (e) {
      final failure = UnknownFailure(message: 'Erro ao criar torneio', originalError: e);
      ErrorHandler.logFailure(failure, context: 'TournamentRepository.createTournament');
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, Tournament>> updateTournament(Tournament tournament) async {
    try {
      final updated = await _datasource.updateTournament(tournament);
      return Right(updated);
    } on Failure catch (failure) {
      ErrorHandler.logFailure(failure, context: 'TournamentRepository.updateTournament');
      return Left(failure);
    } catch (e) {
      final failure = UnknownFailure(message: 'Erro ao atualizar torneio', originalError: e);
      ErrorHandler.logFailure(failure, context: 'TournamentRepository.updateTournament');
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> deleteTournament(String tournamentId) async {
    try {
      await _datasource.deleteTournament(tournamentId);
      return Right(null);
    } on Failure catch (failure) {
      ErrorHandler.logFailure(failure, context: 'TournamentRepository.deleteTournament');
      return Left(failure);
    } catch (e) {
      final failure = UnknownFailure(message: 'Erro ao excluir torneio', originalError: e);
      ErrorHandler.logFailure(failure, context: 'TournamentRepository.deleteTournament');
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, List<Tournament>>> getTournamentsByDate(DateTime date) async {
    try {
      final tournaments = await _datasource.getTournamentsByDate(date);
      return Right(tournaments);
    } on Failure catch (failure) {
      ErrorHandler.logFailure(failure, context: 'TournamentRepository.getTournamentsByDate');
      return Left(failure);
    } catch (e) {
      final failure = UnknownFailure(message: 'Erro ao buscar torneios por data', originalError: e);
      ErrorHandler.logFailure(failure, context: 'TournamentRepository.getTournamentsByDate');
      return Left(failure);
    }
  }
}
