import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/player.dart';
import 'players_datasource.dart';

class PlayersDatasourceImplementation implements IPlayersDatasource {
  final FirebaseFirestore _firestore;

  PlayersDatasourceImplementation(this._firestore);

  CollectionReference get _collection => _firestore.collection('players');

  @override
  Future<List<Player>> getAllPlayers() async {
    try {
      final querySnapshot = await _collection.orderBy('name').get();
      return querySnapshot.docs
          .map((doc) => Player.fromJson(
                doc.data() as Map<String, dynamic>,
                id: doc.id,
              ))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar jogadores: $e');
    }
  }

  @override
  Future<Player> getPlayerById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (!doc.exists) {
        throw Exception('Jogador não encontrado');
      }
      return Player.fromJson(
        doc.data() as Map<String, dynamic>,
        id: doc.id,
      );
    } catch (e) {
      throw Exception('Erro ao buscar jogador: $e');
    }
  }

  @override
  Future<Player> createPlayer(Player player) async {
    try {
      final docRef = await _collection.add(player.toJson());
      final doc = await docRef.get();
      return Player.fromJson(
        doc.data() as Map<String, dynamic>,
        id: doc.id,
      );
    } catch (e) {
      throw Exception('Erro ao criar jogador: $e');
    }
  }

  @override
  Future<Player> updatePlayer(Player player) async {
    try {
      if (player.id == null) {
        throw Exception('ID do jogador é obrigatório para atualização');
      }
      
      final updateData = player.copyWith(updatedAt: DateTime.now()).toJson();
      await _collection.doc(player.id).update(updateData);
      
      final doc = await _collection.doc(player.id).get();
      return Player.fromJson(
        doc.data() as Map<String, dynamic>,
        id: doc.id,
      );
    } catch (e) {
      throw Exception('Erro ao atualizar jogador: $e');
    }
  }

  @override
  Future<void> deletePlayer(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao excluir jogador: $e');
    }
  }

  @override
  Future<List<Player>> searchPlayers(String query) async {
    try {
      final querySnapshot = await _collection
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .orderBy('name')
          .get();
      
      return querySnapshot.docs
          .map((doc) => Player.fromJson(
                doc.data() as Map<String, dynamic>,
                id: doc.id,
              ))
          .toList();
    } catch (e) {
      throw Exception('Erro ao pesquisar jogadores: $e');
    }
  }
}