import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/tournament.dart';
import 'tournament_datasource.dart';

class TournamentDatasourceImplementation implements ITournamentDatasource {
  final FirebaseFirestore _firestore;

  TournamentDatasourceImplementation(this._firestore);

  CollectionReference get _collection => _firestore.collection('tournaments');

  @override
  Future<List<Tournament>> getAllTournaments() async {
    
    try {
      final querySnapshot = await _collection
          .orderBy('createdAt', descending: true)
          .get();
      
      
      final tournaments = querySnapshot.docs
          .map((doc) {
            try {
              final data = doc.data() as Map<String, dynamic>;
              
              final tournament = Tournament.fromJson(data, id: doc.id);
              
              
              // Matches validation could be added here if needed
              
              return tournament;
            } catch (parseError) {
              rethrow;
            }
          })
          .toList();
          
      return tournaments;
    } catch (e) {
      throw Exception('Erro ao buscar torneios: $e');
    }
  }

  @override
  Future<Tournament?> getTournament(String tournamentId) async {
    try {
      final doc = await _collection.doc(tournamentId).get();
      if (!doc.exists) {
        return null;
      }
      
      return Tournament.fromJson(
        doc.data() as Map<String, dynamic>,
        id: doc.id,
      );
    } catch (e) {
      throw Exception('Erro ao buscar torneio: $e');
    }
  }

  @override
  Future<Tournament> createTournament(Tournament tournament) async {
    try {
      final data = tournament.toJson();
      data['createdAt'] = FieldValue.serverTimestamp();
      
      final docRef = await _collection.add(data);
      final doc = await docRef.get();
      
      return Tournament.fromJson(
        doc.data() as Map<String, dynamic>,
        id: doc.id,
      );
    } catch (e) {
      throw Exception('Erro ao criar torneio: $e');
    }
  }

  @override
  Future<Tournament> updateTournament(Tournament tournament) async {
    try {
      if (tournament.id == null) {
        throw Exception('ID do torneio é obrigatório para atualização');
      }

      final updateData = tournament.toJson();
      updateData['updatedAt'] = FieldValue.serverTimestamp();
      
      await _collection.doc(tournament.id).update(updateData);
      
      final doc = await _collection.doc(tournament.id).get();
      return Tournament.fromJson(
        doc.data() as Map<String, dynamic>,
        id: doc.id,
      );
    } catch (e) {
      throw Exception('Erro ao atualizar torneio: $e');
    }
  }

  @override
  Future<void> deleteTournament(String tournamentId) async {
    try {
      await _collection.doc(tournamentId).delete();
    } catch (e) {
      throw Exception('Erro ao excluir torneio: $e');
    }
  }

  @override
  Future<List<Tournament>> getTournamentsByDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
      
      final querySnapshot = await _collection
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .orderBy('date')
          .get();
      
      return querySnapshot.docs
          .map((doc) => Tournament.fromJson(
                doc.data() as Map<String, dynamic>,
                id: doc.id,
              ))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar torneios por data: $e');
    }
  }
}