import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/match.dart';
import 'matches_datasource.dart';

class MatchesDatasourceImplementation implements IMatchesDatasource {
  final FirebaseFirestore _firestore;

  MatchesDatasourceImplementation(this._firestore);

  CollectionReference get _collection => _firestore.collection('matches');

  @override
  Future<List<Match>> getAllMatches() async {
    try {
      final querySnapshot = await _collection
          .orderBy('matchDate', descending: true)
          .get();
      return querySnapshot.docs
          .map((doc) => Match.fromJson(
                doc.data() as Map<String, dynamic>,
                id: doc.id,
              ))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar partidas: $e');
    }
  }

  @override
  Future<Match> getMatchById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (!doc.exists) {
        throw Exception('Partida não encontrada');
      }
      return Match.fromJson(
        doc.data() as Map<String, dynamic>,
        id: doc.id,
      );
    } catch (e) {
      throw Exception('Erro ao buscar partida: $e');
    }
  }

  @override
  Future<Match> createMatch(Match match) async {
    try {
      final docRef = await _collection.add(match.toJson());
      final doc = await docRef.get();
      return Match.fromJson(
        doc.data() as Map<String, dynamic>,
        id: doc.id,
      );
    } catch (e) {
      throw Exception('Erro ao criar partida: $e');
    }
  }

  @override
  Future<Match> updateMatch(Match match) async {
    try {
      if (match.id == null) {
        throw Exception('ID da partida é obrigatório para atualização');
      }
      
      final updateData = match.copyWith(updatedAt: DateTime.now()).toJson();
      await _collection.doc(match.id).update(updateData);
      
      final doc = await _collection.doc(match.id).get();
      return Match.fromJson(
        doc.data() as Map<String, dynamic>,
        id: doc.id,
      );
    } catch (e) {
      throw Exception('Erro ao atualizar partida: $e');
    }
  }

  @override
  Future<void> deleteMatch(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao excluir partida: $e');
    }
  }
}