import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:fominhas/core/extensions/cubit_state_extensions.dart';
import 'package:fominhas/core/errors/failure.dart';
import 'package:fominhas/features/tournament/presentation/cubit/tournament_cubit.dart';
import 'package:fominhas/features/tournament/domain/entities/tournament.dart';
import 'package:fominhas/features/tournament/domain/repositories/tournament_repository.dart';
import 'package:fominhas/features/players/domain/entities/player.dart';

// Mock classes
class MockTournamentRepository extends Mock implements ITournamentRepository {}

// Fake classes
class FakeTournament extends Fake implements Tournament {}

void main() {
  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(FakeTournament());
  });

  group('TournamentCubit Tests', () {
    late TournamentCubit cubit;
    late MockTournamentRepository mockRepository;
    late List<Tournament> mockTournaments;
    late Tournament mockTournament;

    setUp(() {
      mockRepository = MockTournamentRepository();
      cubit = TournamentCubit(mockRepository);

      // Create mock data
      final mockPlayer = Player(
        id: 'player1',
        name: 'Test Player',
        position: PlayerPosition.goleiro,
        jerseyNumber: 1,
        createdAt: DateTime.now(),
        stats: const PlayerStats(),
      );

      final mockTeam = TournamentTeam(
        id: 'team1',
        name: 'Test Team',
        players: [mockPlayer],
      );

      mockTournament = Tournament(
        id: 'tournament1',
        name: 'Test Tournament',
        date: DateTime.now(),
        teams: [mockTeam],
        matches: [],
        createdAt: DateTime.now(),
      );

      mockTournaments = [mockTournament];
    });

    tearDown(() {
      cubit.close();
    });

    group('loadTournaments', () {
      test('should emit success with tournaments list', () async {
        // Arrange
        when(() => mockRepository.getAllTournaments())
            .thenAnswer((_) async => Right(mockTournaments));

        // Act
        await cubit.loadTournaments();

        // Assert
        expect(cubit.state.isSuccess, true);
        final tournaments = CubitStateHelper.getList<Tournament>(cubit.state);
        expect(tournaments.length, 1);
        expect(tournaments.first.id, 'tournament1');

        // Verify repository call
        verify(() => mockRepository.getAllTournaments()).called(1);
      });

      test('should emit error on repository failure', () async {
        // Arrange
        when(() => mockRepository.getAllTournaments())
            .thenAnswer((_) async => Left(UnknownFailure(message: 'Repository error')));

        // Act
        await cubit.loadTournaments();

        // Assert
        expect(cubit.state.isError, true);
        expect(cubit.state.getErrorMessage(), contains('Repository error'));
      });
    });

    group('loadTournament', () {
      test('should emit success with specific tournament', () async {
        // Arrange
        when(() => mockRepository.getTournament('tournament1'))
            .thenAnswer((_) async => Right(mockTournament));

        // Act
        await cubit.loadTournament('tournament1');

        // Assert
        expect(cubit.state.isSuccess, true);
        final tournament = cubit.state.getSuccessValue<Tournament>();
        expect(tournament?.id, 'tournament1');
        expect(cubit.currentTournament?.id, 'tournament1');

        verify(() => mockRepository.getTournament('tournament1')).called(1);
      });

      test('should emit error when tournament not found', () async {
        // Arrange
        when(() => mockRepository.getTournament('nonexistent'))
            .thenAnswer((_) async => Right(null));

        // Act
        await cubit.loadTournament('nonexistent');

        // Assert
        expect(cubit.state.isError, true);
        expect(cubit.state.getErrorMessage(), 'Torneio não encontrado');
      });
    });

    group('createTournament', () {
      test('should emit success with created tournament', () async {
        // Arrange
        final createdTournament = mockTournament.copyWith(id: 'new_tournament');
        when(() => mockRepository.createTournament(any()))
            .thenAnswer((_) async => Right(createdTournament));

        // Act
        await cubit.createTournament(
          name: 'New Tournament',
          date: DateTime.now(),
          teams: mockTournament.teams,
          matches: [],
        );

        // Assert
        expect(cubit.state.isSuccess, true);
        final tournament = cubit.state.getSuccessValue<Tournament>();
        expect(tournament?.id, 'new_tournament');
        expect(cubit.currentTournament?.id, 'new_tournament');

        verify(() => mockRepository.createTournament(any())).called(1);
      });

      test('should emit error on creation failure', () async {
        // Arrange
        when(() => mockRepository.createTournament(any()))
            .thenAnswer((_) async => Left(UnknownFailure(message: 'Creation failed')));

        // Act
        await cubit.createTournament(
          name: 'New Tournament',
          date: DateTime.now(),
          teams: mockTournament.teams,
          matches: [],
        );

        // Assert
        expect(cubit.state.isError, true);
        expect(cubit.state.getErrorMessage(), contains('Creation failed'));
      });
    });

    group('initial state', () {
      test('should start with empty state', () {
        expect(cubit.state.isEmpty, true);
        expect(cubit.currentTournament, null);
      });
    });
  });
}