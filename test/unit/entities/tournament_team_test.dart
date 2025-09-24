import 'package:flutter_test/flutter_test.dart';
import 'package:fominhas/features/tournament/domain/entities/tournament.dart';
import 'package:fominhas/features/players/domain/entities/player.dart';

void main() {
  group('TournamentTeam Entity Tests', () {
    late TournamentTeam team;
    late List<Player> mockPlayers;
    late List<Player> mockReserves;
    late DateTime mockCreatedAt;

    setUp(() {
      mockCreatedAt = DateTime(2024, 1, 14);

      // Create mock players
      mockPlayers = [
        Player(
          id: 'player1',
          name: 'João Goleiro',
          position: PlayerPosition.goleiro,
          jerseyNumber: 1,
          createdAt: mockCreatedAt,
          stats: const PlayerStats(),
        ),
        Player(
          id: 'player2',
          name: 'Pedro Fixo',
          position: PlayerPosition.fixo,
          jerseyNumber: 2,
          createdAt: mockCreatedAt,
          stats: const PlayerStats(),
        ),
        Player(
          id: 'player3',
          name: 'Carlos Ala',
          position: PlayerPosition.ala,
          jerseyNumber: 3,
          createdAt: mockCreatedAt,
          stats: const PlayerStats(),
        ),
        Player(
          id: 'player4',
          name: 'Lucas Pivô',
          position: PlayerPosition.pivo,
          jerseyNumber: 4,
          createdAt: mockCreatedAt,
          stats: const PlayerStats(),
        ),
      ];

      mockReserves = [
        Player(
          id: 'reserve1',
          name: 'Reserve 1',
          position: PlayerPosition.ala,
          jerseyNumber: 5,
          createdAt: mockCreatedAt,
          stats: const PlayerStats(),
        ),
      ];

      team = TournamentTeam(
        id: 'team1',
        name: 'Time Azul',
        players: mockPlayers,
        reserves: mockReserves,
        points: 9,
        goalsScored: 12,
        goalsConceded: 8,
        wins: 3,
        draws: 0,
        losses: 1,
      );
    });

    test('should create TournamentTeam with required parameters', () {
      expect(team.id, 'team1');
      expect(team.name, 'Time Azul');
      expect(team.players, mockPlayers);
      expect(team.reserves, mockReserves);
      expect(team.points, 9);
      expect(team.goalsScored, 12);
      expect(team.goalsConceded, 8);
      expect(team.wins, 3);
      expect(team.draws, 0);
      expect(team.losses, 1);
    });

    test('should create TournamentTeam with default values', () {
      final defaultTeam = TournamentTeam(
        id: 'team2',
        name: 'Time Branco',
        players: mockPlayers,
      );

      expect(defaultTeam.reserves, isEmpty);
      expect(defaultTeam.points, 0);
      expect(defaultTeam.goalsScored, 0);
      expect(defaultTeam.goalsConceded, 0);
      expect(defaultTeam.wins, 0);
      expect(defaultTeam.draws, 0);
      expect(defaultTeam.losses, 0);
    });

    test('goalDifference should be calculated correctly', () {
      expect(team.goalDifference, 4); // 12 - 8 = 4
      
      final negativeTeam = TournamentTeam(
        id: 'team3',
        name: 'Time Ruim',
        players: mockPlayers,
        goalsScored: 3,
        goalsConceded: 7,
      );
      
      expect(negativeTeam.goalDifference, -4); // 3 - 7 = -4
    });

    test('matchesPlayed should be calculated correctly', () {
      expect(team.matchesPlayed, 4); // 3 + 0 + 1 = 4
      
      final newTeam = TournamentTeam(
        id: 'team4',
        name: 'Time Novo',
        players: mockPlayers,
        wins: 2,
        draws: 1,
        losses: 0,
      );
      
      expect(newTeam.matchesPlayed, 3); // 2 + 1 + 0 = 3
    });

    test('copyWith should create new instance with updated values', () {
      final updatedTeam = team.copyWith(
        name: 'Time Verde',
        points: 12,
        goalsScored: 15,
        wins: 4,
      );

      expect(updatedTeam.name, 'Time Verde');
      expect(updatedTeam.points, 12);
      expect(updatedTeam.goalsScored, 15);
      expect(updatedTeam.wins, 4);
      expect(updatedTeam.id, team.id);
      expect(updatedTeam.goalsConceded, team.goalsConceded);
      expect(updatedTeam.draws, team.draws);
      expect(updatedTeam.losses, team.losses);
    });

    test('toJson should serialize TournamentTeam correctly', () {
      final json = team.toJson();

      expect(json['id'], 'team1');
      expect(json['name'], 'Time Azul');
      expect(json['players'], isA<List>());
      expect(json['reserves'], isA<List>());
      expect(json['points'], 9);
      expect(json['goalsScored'], 12);
      expect(json['goalsConceded'], 8);
      expect(json['wins'], 3);
      expect(json['draws'], 0);
      expect(json['losses'], 1);
      expect(json['players'], hasLength(4));
      expect(json['reserves'], hasLength(1));
    });

    test('fromJson should deserialize TournamentTeam correctly', () {
      final json = {
        'id': 'team_from_json',
        'name': 'Time do JSON',
        'players': [],
        'reserves': [],
        'points': 6,
        'goalsScored': 8,
        'goalsConceded': 5,
        'wins': 2,
        'draws': 0,
        'losses': 1,
      };

      final deserializedTeam = TournamentTeam.fromJson(json);

      expect(deserializedTeam.id, 'team_from_json');
      expect(deserializedTeam.name, 'Time do JSON');
      expect(deserializedTeam.players, isEmpty);
      expect(deserializedTeam.reserves, isEmpty);
      expect(deserializedTeam.points, 6);
      expect(deserializedTeam.goalsScored, 8);
      expect(deserializedTeam.goalsConceded, 5);
      expect(deserializedTeam.wins, 2);
      expect(deserializedTeam.draws, 0);
      expect(deserializedTeam.losses, 1);
    });

    test('should handle null/empty values in fromJson', () {
      final json = <String, dynamic>{};
      
      final team = TournamentTeam.fromJson(json);

      expect(team.id, '');
      expect(team.name, '');
      expect(team.players, isEmpty);
      expect(team.reserves, isEmpty);
      expect(team.points, 0);
      expect(team.goalsScored, 0);
      expect(team.goalsConceded, 0);
      expect(team.wins, 0);
      expect(team.draws, 0);
      expect(team.losses, 0);
    });

    test('equality should work correctly with Equatable', () {
      final team1 = TournamentTeam(
        id: 'same_id',
        name: 'Same Team',
        players: mockPlayers,
        reserves: mockReserves,
        points: 6,
        goalsScored: 10,
        goalsConceded: 4,
        wins: 2,
        draws: 0,
        losses: 0,
      );

      final team2 = TournamentTeam(
        id: 'same_id',
        name: 'Same Team',
        players: mockPlayers,
        reserves: mockReserves,
        points: 6,
        goalsScored: 10,
        goalsConceded: 4,
        wins: 2,
        draws: 0,
        losses: 0,
      );

      final team3 = TournamentTeam(
        id: 'different_id',
        name: 'Same Team',
        players: mockPlayers,
        reserves: mockReserves,
        points: 6,
        goalsScored: 10,
        goalsConceded: 4,
        wins: 2,
        draws: 0,
        losses: 0,
      );

      expect(team1, equals(team2));
      expect(team1, isNot(equals(team3)));
      expect(team1.hashCode, equals(team2.hashCode));
      expect(team1.hashCode, isNot(equals(team3.hashCode)));
    });

    test('should handle team statistics correctly', () {
      // Test team with perfect record
      final perfectTeam = TournamentTeam(
        id: 'perfect',
        name: 'Perfect Team',
        players: mockPlayers,
        wins: 5,
        draws: 0,
        losses: 0,
        points: 15,
        goalsScored: 20,
        goalsConceded: 2,
      );

      expect(perfectTeam.matchesPlayed, 5);
      expect(perfectTeam.goalDifference, 18);
      expect(perfectTeam.points, 15);

      // Test team with mixed record
      final mixedTeam = TournamentTeam(
        id: 'mixed',
        name: 'Mixed Team',
        players: mockPlayers,
        wins: 2,
        draws: 2,
        losses: 1,
        points: 8, // 2*3 + 2*1 + 1*0 = 8
        goalsScored: 10,
        goalsConceded: 8,
      );

      expect(mixedTeam.matchesPlayed, 5);
      expect(mixedTeam.goalDifference, 2);
      expect(mixedTeam.points, 8);
    });
  });
}