import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/services/error_handler.dart';
import '../../domain/entities/player.dart';
import '../../domain/repositories/players_repository.dart';
import '../datasource/players_datasource.dart';

class PlayersRepositoryImplementation implements IPlayersRepository {
  final IPlayersDatasource _datasource;

  PlayersRepositoryImplementation(this._datasource);

  @override
  Future<Either<Failure, List<Player>>> getAllPlayers() async {
    try {
      final players = await _datasource.getAllPlayers();
      return Right(players);
    } on DataPostFailure catch (e) {
      ErrorHandler.logFailure(e, context: 'PlayersRepository.getAllPlayers');
      return Left(e);
    } catch (e) {
      final failure = UnknownFailure(
        message: 'Erro ao carregar jogadores',
        originalError: e,
      );
      ErrorHandler.logFailure(failure, context: 'PlayersRepository.getAllPlayers');
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, Player>> getPlayerById(String id) async {
    try {
      final player = await _datasource.getPlayerById(id);
      return Right(player);
    } on DataPostFailure catch (e) {
      ErrorHandler.logFailure(e, context: 'PlayersRepository.getPlayerById');
      return Left(e);
    } catch (e) {
      final failure = UnknownFailure(
        message: 'Erro ao buscar jogador',
        originalError: e,
      );
      ErrorHandler.logFailure(failure, context: 'PlayersRepository.getPlayerById');
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, Player>> createPlayer(Player player) async {
    try {
      final createdPlayer = await _datasource.createPlayer(player);
      return Right(createdPlayer);
    } on DataPostFailure catch (e) {
      ErrorHandler.logFailure(e, context: 'PlayersRepository.createPlayer');
      return Left(e);
    } catch (e) {
      final failure = UnknownFailure(
        message: 'Erro ao criar jogador',
        originalError: e,
      );
      ErrorHandler.logFailure(failure, context: 'PlayersRepository.createPlayer');
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, Player>> updatePlayer(Player player) async {
    try {
      final updatedPlayer = await _datasource.updatePlayer(player);
      return Right(updatedPlayer);
    } on DataPostFailure catch (e) {
      ErrorHandler.logFailure(e, context: 'PlayersRepository.updatePlayer');
      return Left(e);
    } catch (e) {
      final failure = UnknownFailure(
        message: 'Erro ao atualizar jogador',
        originalError: e,
      );
      ErrorHandler.logFailure(failure, context: 'PlayersRepository.updatePlayer');
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> deletePlayer(String id) async {
    try {
      await _datasource.deletePlayer(id);
      return Right(null);
    } on DataPostFailure catch (e) {
      ErrorHandler.logFailure(e, context: 'PlayersRepository.deletePlayer');
      return Left(e);
    } catch (e) {
      final failure = UnknownFailure(
        message: 'Erro ao excluir jogador',
        originalError: e,
      );
      ErrorHandler.logFailure(failure, context: 'PlayersRepository.deletePlayer');
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, List<Player>>> searchPlayers(String query) async {
    try {
      final players = await _datasource.searchPlayers(query);
      return Right(players);
    } on DataPostFailure catch (e) {
      ErrorHandler.logFailure(e, context: 'PlayersRepository.searchPlayers');
      return Left(e);
    } catch (e) {
      final failure = UnknownFailure(
        message: 'Erro ao buscar jogadores',
        originalError: e,
      );
      ErrorHandler.logFailure(failure, context: 'PlayersRepository.searchPlayers');
      return Left(failure);
    }
  }
}
