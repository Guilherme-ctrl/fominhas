import '../../domain/entities/player.dart';

abstract class IPlayersDatasource {
  Future<List<Player>> getAllPlayers();
  Future<Player> getPlayerById(String id);
  Future<Player> createPlayer(Player player);
  Future<Player> updatePlayer(Player player);
  Future<void> deletePlayer(String id);
  Future<List<Player>> searchPlayers(String query);
}