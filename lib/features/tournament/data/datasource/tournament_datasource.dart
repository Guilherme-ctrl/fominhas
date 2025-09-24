import '../../domain/entities/tournament.dart';

abstract class ITournamentDatasource {
  Future<List<Tournament>> getAllTournaments();
  Future<Tournament?> getTournament(String tournamentId);
  Future<Tournament> createTournament(Tournament tournament);
  Future<Tournament> updateTournament(Tournament tournament);
  Future<void> deleteTournament(String tournamentId);
  Future<List<Tournament>> getTournamentsByDate(DateTime date);
}