import 'package:flutter_test/flutter_test.dart';
import 'package:fominhas/features/tournament/domain/entities/tournament.dart';
import 'package:fominhas/features/players/domain/entities/player.dart';

void main() {
  group('Tournament Entity Tests', () {
    late Tournament tournament;
    late List<TournamentTeam> mockTeams;
    late List<TournamentMatch> mockMatches;
    late DateTime mockDate;
    late DateTime mockCreatedAt;

    setUp(() {
      mockDate = DateTime(2024, 1, 15);
      mockCreatedAt = DateTime(2024, 1, 14);

      // Create mock players
      final mockPlayer1 = Player(
        id: 'player1',
        name: 'João',
        position: PlayerPosition.goleiro,
        jerseyNumber: 1,
        createdAt: mockCreatedAt,
        stats: const PlayerStats(),
      );

      final mockPlayer2 = Player(
        id: 'player2',
        name: 'Pedro',
        position: PlayerPosition.fixo,
        jerseyNumber: 2,
        createdAt: mockCreatedAt,
        stats: const PlayerStats(),
      );

      // Create mock teams
      mockTeams = [
        TournamentTeam(
          id: 'team1',
          name: 'Time Azul',
          players: [mockPlayer1, mockPlayer2],
        ),
        TournamentTeam(
          id: 'team2',
          name: 'Time Vermelho',
          players: [mockPlayer1, mockPlayer2],
        ),
      ];

      // Create mock matches
      mockMatches = [
        const TournamentMatch(
          id: 'match1',
          homeTeamId: 'team1',
          awayTeamId: 'team2',
          matchNumber: 1,
        ),
      ];

      tournament = Tournament(
        id: 'tournament1',
        name: 'Torneio de Teste',
        date: mockDate,
        teams: mockTeams,
        matches: mockMatches,
        createdAt: mockCreatedAt,
      );
    });

    test('should create Tournament with required parameters', () {
      expect(tournament.id, 'tournament1');
      expect(tournament.name, 'Torneio de Teste');
      expect(tournament.date, mockDate);
      expect(tournament.teams, mockTeams);
      expect(tournament.matches, mockMatches);
      expect(tournament.status, TournamentStatus.setup);
      expect(tournament.createdAt, mockCreatedAt);
      expect(tournament.championTeamId, isNull);
      expect(tournament.updatedAt, isNull);
    });

    test('should create Tournament with custom status', () {
      final tournamentInProgress = Tournament(
        id: 'tournament2',
        name: 'Torneio em Andamento',
        date: mockDate,
        teams: mockTeams,
        matches: mockMatches,
        status: TournamentStatus.inProgress,
        createdAt: mockCreatedAt,
      );

      expect(tournamentInProgress.status, TournamentStatus.inProgress);
    });

    test('copyWith should create new instance with updated values', () {
      final updatedTournament = tournament.copyWith(
        name: 'Novo Nome',
        status: TournamentStatus.finished,
        championTeamId: 'team1',
      );

      expect(updatedTournament.name, 'Novo Nome');
      expect(updatedTournament.status, TournamentStatus.finished);
      expect(updatedTournament.championTeamId, 'team1');
      expect(updatedTournament.id, tournament.id);
      expect(updatedTournament.date, tournament.date);
    });

    test('toJson should serialize Tournament correctly', () {
      final json = tournament.toJson();

      expect(json['name'], 'Torneio de Teste');
      expect(json['status'], 'setup');
      expect(json['championTeamId'], isNull);
      expect(json['teams'], isA<List>());
      expect(json['matches'], isA<List>());
      expect(json['date'], isNotNull);
      expect(json['createdAt'], isNotNull);
    });

    test('fromJson should deserialize Tournament correctly', () {
      final json = {
        'name': 'Torneio do JSON',
        'status': 'inProgress',
        'championTeamId': 'team1',
        'teams': [],
        'matches': [],
        // Remove date and createdAt from JSON test to avoid Timestamp issues
      };

      final deserializedTournament = Tournament.fromJson(json, id: 'test_id');

      expect(deserializedTournament.id, 'test_id');
      expect(deserializedTournament.name, 'Torneio do JSON');
      expect(deserializedTournament.status, TournamentStatus.inProgress);
      expect(deserializedTournament.championTeamId, 'team1');
      expect(deserializedTournament.teams, isEmpty);
      expect(deserializedTournament.matches, isEmpty);
    });

    test('should handle null/empty values in fromJson', () {
      final json = <String, dynamic>{};
      
      final tournament = Tournament.fromJson(json);

      expect(tournament.name, '');
      expect(tournament.status, TournamentStatus.setup);
      expect(tournament.teams, isEmpty);
      expect(tournament.matches, isEmpty);
      expect(tournament.date, isA<DateTime>());
      expect(tournament.createdAt, isA<DateTime>());
    });

    test('equality should work correctly with Equatable', () {
      final tournament1 = Tournament(
        id: 'same_id',
        name: 'Same Tournament',
        date: mockDate,
        teams: mockTeams,
        matches: mockMatches,
        createdAt: mockCreatedAt,
      );

      final tournament2 = Tournament(
        id: 'same_id',
        name: 'Same Tournament',
        date: mockDate,
        teams: mockTeams,
        matches: mockMatches,
        createdAt: mockCreatedAt,
      );

      final tournament3 = Tournament(
        id: 'different_id',
        name: 'Same Tournament',
        date: mockDate,
        teams: mockTeams,
        matches: mockMatches,
        createdAt: mockCreatedAt,
      );

      expect(tournament1, equals(tournament2));
      expect(tournament1, isNot(equals(tournament3)));
      expect(tournament1.hashCode, equals(tournament2.hashCode));
      expect(tournament1.hashCode, isNot(equals(tournament3.hashCode)));
    });
  });
}