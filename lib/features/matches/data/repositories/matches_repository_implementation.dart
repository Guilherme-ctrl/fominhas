import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/services/error_handler.dart';
import '../../domain/entities/match.dart';
import '../../domain/repositories/matches_repository.dart';
import '../datasource/matches_datasource.dart';

class MatchesRepositoryImplementation implements IMatchesRepository {
  final IMatchesDatasource _datasource;

  MatchesRepositoryImplementation(this._datasource);

  @override
  Future<Either<Failure, List<Match>>> getAllMatches() async {
    try {
      final matches = await _datasource.getAllMatches();
      return Right(matches);
    } on DataPostFailure catch (e) {
      ErrorHandler.logFailure(e, context: 'MatchesRepository.getAllMatches');
      return Left(e);
    } catch (e) {
      final failure = UnknownFailure(message: 'Erro ao carregar partidas', originalError: e);
      ErrorHandler.logFailure(failure, context: 'MatchesRepository.getAllMatches');
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, Match>> getMatchById(String id) async {
    try {
      final match = await _datasource.getMatchById(id);
      return Right(match);
    } on DataPostFailure catch (e) {
      ErrorHandler.logFailure(e, context: 'MatchesRepository.getMatchById');
      return Left(e);
    } catch (e) {
      final failure = UnknownFailure(message: 'Erro ao buscar partida', originalError: e);
      ErrorHandler.logFailure(failure, context: 'MatchesRepository.getMatchById');
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, Match>> createMatch(Match match) async {
    try {
      final created = await _datasource.createMatch(match);
      return Right(created);
    } on DataPostFailure catch (e) {
      ErrorHandler.logFailure(e, context: 'MatchesRepository.createMatch');
      return Left(e);
    } catch (e) {
      final failure = UnknownFailure(message: 'Erro ao criar partida', originalError: e);
      ErrorHandler.logFailure(failure, context: 'MatchesRepository.createMatch');
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, Match>> updateMatch(Match match) async {
    try {
      final updated = await _datasource.updateMatch(match);
      return Right(updated);
    } on DataPostFailure catch (e) {
      ErrorHandler.logFailure(e, context: 'MatchesRepository.updateMatch');
      return Left(e);
    } catch (e) {
      final failure = UnknownFailure(message: 'Erro ao atualizar partida', originalError: e);
      ErrorHandler.logFailure(failure, context: 'MatchesRepository.updateMatch');
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> deleteMatch(String id) async {
    try {
      await _datasource.deleteMatch(id);
      return Right(null);
    } on DataPostFailure catch (e) {
      ErrorHandler.logFailure(e, context: 'MatchesRepository.deleteMatch');
      return Left(e);
    } catch (e) {
      final failure = UnknownFailure(message: 'Erro ao excluir partida', originalError: e);
      ErrorHandler.logFailure(failure, context: 'MatchesRepository.deleteMatch');
      return Left(failure);
    }
  }
}
