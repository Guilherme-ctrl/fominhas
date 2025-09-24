import '../../domain/entities/match.dart';

abstract class IMatchesDatasource {
  Future<List<Match>> getAllMatches();
  Future<Match> getMatchById(String id);
  Future<Match> createMatch(Match match);
  Future<Match> updateMatch(Match match);
  Future<void> deleteMatch(String id);
}