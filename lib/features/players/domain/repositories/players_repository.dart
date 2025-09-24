import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/player.dart';

abstract class IPlayersRepository {
  Future<Either<Failure, List<Player>>> getAllPlayers();
  Future<Either<Failure, Player>> getPlayerById(String id);
  Future<Either<Failure, Player>> createPlayer(Player player);
  Future<Either<Failure, Player>> updatePlayer(Player player);
  Future<Either<Failure, void>> deletePlayer(String id);
  Future<Either<Failure, List<Player>>> searchPlayers(String query);
}
