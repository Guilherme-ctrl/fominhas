import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:fominhas/core/state/cubit_state.dart';
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

// Versão do cubit que não faz logging (para testes)
class TestTournamentCubit extends TournamentCubit {
  TestTournamentCubit(super.repository);

  // Override para não fazer logging nos testes
  @override
  void logOperation(String operation, {Map<String, dynamic>? data}) {
    // Não faz nada nos testes
  }

  @override
  void logError(String operation, Object error, {StackTrace? stackTrace}) {
    // Não faz nada nos testes
  }
}

void main() {
  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(FakeTournament());
  });

  group('TournamentCubit Tests', () {
    late TestTournamentCubit cubit;
    late MockTournamentRepository mockRepository;
    late List<Tournament> mockTournaments;
    late Tournament mockTournament;

    setUp(() {
      mockRepository = MockTournamentRepository();
      cubit = TestTournamentCubit(mockRepository);

      // Create mock data
      final mockPlayer = Player(
        id: 'player1',
        name: 'Test Player',
        position: PlayerPosition.goleiro,
        jerseyNumber: 1,
        createdAt: DateTime.now(),
        stats: const PlayerStats(),
      );

      final mockTeam = TournamentTeam(id: 'team1', name: 'Test Team', players: [mockPlayer]);

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
      test('should emit loading then success with tournaments list', () async {
        // Arrange
        when(() => mockRepository.getAllTournaments()).thenAnswer((_) async => Right(mockTournaments));

        // Act & Assert
        expectLater(
          cubit.stream,
          emitsInOrder([
            predicate<CubitState>((state) => state.isLoading),
            predicate<CubitState>((state) {
              final tournaments = CubitStateHelper.getList<Tournament>(state);
              return state.isSuccess && tournaments.length == 1;
            }),
          ]),
        );

        await cubit.loadTournaments();

        // Verify repository call
        verify(() => mockRepository.getAllTournaments()).called(1);
      });

      test('should emit loading then error on repository failure', () async {
        // Arrange
        when(() => mockRepository.getAllTournaments()).thenAnswer((_) async => Left(UnknownFailure(message: 'Repository error')));

        // Act & Assert
        expectLater(
          cubit.stream,
          emitsInOrder([
            predicate<CubitState>((state) => state.isLoading),
            predicate<CubitState>((state) => state.isError && state.getErrorMessage()!.contains('Repository error')),
          ]),
        );

        await cubit.loadTournaments();
      });
    });

    group('loadCurrentTournament', () {
      test('should return cached tournament if available', () async {
        // Arrange - first set a tournament
        when(() => mockRepository.getTournament('tournament1')).thenAnswer((_) async => Right(mockTournament));

        await cubit.loadTournament('tournament1');

        // Act - now load current tournament should return cached
        expect(cubit.currentTournament, isNotNull);
        expect(cubit.currentTournament?.id, 'tournament1');
      });

      test('should emit error when no tournaments exist', () async {
        // Arrange
        when(() => mockRepository.getAllTournaments()).thenAnswer((_) async => Right(<Tournament>[]));

        // Act & Assert
        expectLater(
          cubit.stream,
          emitsInOrder([
            predicate<CubitState>((state) => state.isLoading),
            predicate<CubitState>((state) => state.isError && state.getErrorMessage() == 'Nenhum torneio encontrado'),
          ]),
        );

        await cubit.loadCurrentTournament();
      });

      test('should prioritize in-progress tournaments', () async {
        // Arrange
        final inProgressTournament = mockTournament.copyWith(id: 'tournament2', status: TournamentStatus.inProgress);
        final finishedTournament = mockTournament.copyWith(status: TournamentStatus.finished);

        when(() => mockRepository.getAllTournaments()).thenAnswer((_) async => Right([finishedTournament, inProgressTournament]));

        // Act
        await cubit.loadCurrentTournament();

        // Assert
        expect(cubit.state.isSuccess, true);
        final currentTournament = cubit.state.getSuccessValue<Tournament>();
        expect(currentTournament?.id, 'tournament2');
        expect(currentTournament?.status, TournamentStatus.inProgress);
      });
    });

    group('loadTournament', () {
      test('should emit loading then success with specific tournament', () async {
        // Arrange
        when(() => mockRepository.getTournament('tournament1')).thenAnswer((_) async => Right(mockTournament));

        // Act & Assert
        expectLater(
          cubit.stream,
          emitsInOrder([
            predicate<CubitState>((state) => state.isLoading),
            predicate<CubitState>((state) {
              final tournament = state.getSuccessValue<Tournament>();
              return state.isSuccess && tournament?.id == 'tournament1';
            }),
          ]),
        );

        await cubit.loadTournament('tournament1');

        verify(() => mockRepository.getTournament('tournament1')).called(1);
      });

      test('should emit error when tournament not found', () async {
        // Arrange
        when(() => mockRepository.getTournament('nonexistent')).thenAnswer((_) async => Right(null));

        // Act & Assert
        expectLater(
          cubit.stream,
          emitsInOrder([
            predicate<CubitState>((state) => state.isLoading),
            predicate<CubitState>((state) => state.isError && state.getErrorMessage() == 'Torneio não encontrado'),
          ]),
        );

        await cubit.loadTournament('nonexistent');
      });
    });

    group('createTournament', () {
      test('should emit loading then success with created tournament', () async {
        // Arrange
        final createdTournament = mockTournament.copyWith(id: 'new_tournament');
        when(() => mockRepository.createTournament(any())).thenAnswer((_) async => Right(createdTournament));

        // Act & Assert
        expectLater(
          cubit.stream,
          emitsInOrder([
            predicate<CubitState>((state) => state.isLoading),
            predicate<CubitState>((state) {
              final tournament = state.getSuccessValue<Tournament>();
              return state.isSuccess && tournament?.id == 'new_tournament';
            }),
          ]),
        );

        await cubit.createTournament(name: 'New Tournament', date: DateTime.now(), teams: mockTournament.teams, matches: []);

        verify(() => mockRepository.createTournament(any())).called(1);
      });

      test('should emit error on creation failure', () async {
        // Arrange
        when(() => mockRepository.createTournament(any())).thenAnswer((_) async => Left(UnknownFailure(message: 'Creation failed')));

        // Act & Assert
        expectLater(
          cubit.stream,
          emitsInOrder([
            predicate<CubitState>((state) => state.isLoading),
            predicate<CubitState>((state) => state.isError && state.getErrorMessage()!.contains('Creation failed')),
          ]),
        );

        await cubit.createTournament(name: 'New Tournament', date: DateTime.now(), teams: mockTournament.teams, matches: []);
      });
    });

    group('updateTournament', () {
      test('should emit success with updated tournament', () async {
        // Arrange
        final updatedTournament = mockTournament.copyWith(name: 'Updated Tournament');
        when(() => mockRepository.updateTournament(any())).thenAnswer((_) async => Right(updatedTournament));

        // Act & Assert
        expectLater(
          cubit.stream,
          emits(
            predicate<CubitState>((state) {
              final tournament = state.getSuccessValue<Tournament>();
              return state.isSuccess && tournament?.name == 'Updated Tournament';
            }),
          ),
        );

        await cubit.updateTournament(mockTournament);

        verify(() => mockRepository.updateTournament(any())).called(1);
      });

      test('should emit error on update failure', () async {
        // Arrange
        when(() => mockRepository.updateTournament(any())).thenAnswer((_) async => Left(UnknownFailure(message: 'Update failed')));

        // Act & Assert
        expectLater(cubit.stream, emits(predicate<CubitState>((state) => state.isError && state.getErrorMessage()!.contains('Update failed'))));

        await cubit.updateTournament(mockTournament);
      });
    });

    group('deleteTournament', () {
      test('should remove tournament from list when state has tournaments', () async {
        // Arrange - first load tournaments
        when(() => mockRepository.getAllTournaments()).thenAnswer((_) async => Right(mockTournaments));
        await cubit.loadTournaments();

        // Setup delete
        when(() => mockRepository.deleteTournament('tournament1')).thenAnswer((_) async => Right(null));

        // Act & Assert
        expectLater(
          cubit.stream,
          emits(
            predicate<CubitState>((state) {
              final tournaments = CubitStateHelper.getList<Tournament>(state);
              return state.isSuccess && tournaments.isEmpty;
            }),
          ),
        );

        await cubit.deleteTournament('tournament1');

        verify(() => mockRepository.deleteTournament('tournament1')).called(1);
      });

      test('should emit error on deletion failure', () async {
        // Arrange
        when(() => mockRepository.deleteTournament('tournament1')).thenAnswer((_) async => Left(UnknownFailure(message: 'Deletion failed')));

        // Act & Assert
        expectLater(cubit.stream, emits(predicate<CubitState>((state) => state.isError && state.getErrorMessage()!.contains('Deletion failed'))));

        await cubit.deleteTournament('tournament1');
      });
    });

    group('initial state', () {
      test('should start with empty state', () {
        expect(cubit.state.isEmpty, true);
        expect(cubit.currentTournament, null);
      });
    });

    group('currentTournament getter', () {
      test('should return null when no tournament is loaded', () {
        expect(cubit.currentTournament, null);
      });

      test('should return tournament when one is loaded', () async {
        // Arrange
        when(() => mockRepository.getTournament('tournament1')).thenAnswer((_) async => Right(mockTournament));

        // Act
        await cubit.loadTournament('tournament1');

        // Assert
        expect(cubit.currentTournament, isNotNull);
        expect(cubit.currentTournament?.id, 'tournament1');
      });
    });
  });
}
