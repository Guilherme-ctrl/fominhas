import 'package:flutter_test/flutter_test.dart';
import 'package:fominhas/core/state/cubit_state.dart';
import 'package:fominhas/core/extensions/cubit_state_extensions.dart';
import 'package:fominhas/features/tournament/domain/entities/tournament.dart';
import 'package:fominhas/features/players/domain/entities/player.dart';

void main() {
  group('CubitState with Tournament Tests', () {
    late Tournament mockTournament;
    late List<Tournament> mockTournaments;
    late DateTime mockDate;
    late DateTime mockCreatedAt;

    setUp(() {
      mockDate = DateTime(2024, 1, 15);
      mockCreatedAt = DateTime(2024, 1, 14);

      // Create mock player
      final mockPlayer = Player(
        id: 'player1',
        name: 'João',
        position: PlayerPosition.goleiro,
        jerseyNumber: 1,
        createdAt: mockCreatedAt,
        stats: const PlayerStats(),
      );

      // Create mock teams
      final mockTeams = [
        TournamentTeam(
          id: 'team1',
          name: 'Time Azul',
          players: [mockPlayer],
        ),
        TournamentTeam(
          id: 'team2',
          name: 'Time Vermelho',
          players: [mockPlayer],
        ),
      ];

      // Create mock matches
      final mockMatches = [
        const TournamentMatch(
          id: 'match1',
          homeTeamId: 'team1',
          awayTeamId: 'team2',
          matchNumber: 1,
        ),
      ];

      mockTournament = Tournament(
        id: 'tournament1',
        name: 'Torneio de Teste',
        date: mockDate,
        teams: mockTeams,
        matches: mockMatches,
        createdAt: mockCreatedAt,
      );

      mockTournaments = [
        mockTournament,
        Tournament(
          id: 'tournament2',
          name: 'Segundo Torneio',
          date: mockDate.add(const Duration(days: 1)),
          teams: mockTeams,
          matches: mockMatches,
          createdAt: mockCreatedAt,
        ),
      ];
    });

    group('EmptyCubitState', () {
      test('should be empty state', () {
        final state = CubitState.empty();
        expect(state.isEmpty, isTrue);
        expect(state.isLoading, isFalse);
        expect(state.isSuccess, isFalse);
        expect(state.isError, isFalse);
      });

      test('should be equal to other empty states', () {
        final state1 = CubitState.empty();
        final state2 = CubitState.empty();

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });
    });

    group('LoadingCubitState', () {
      test('should be loading state', () {
        final state = CubitState.loading();
        expect(state.isLoading, isTrue);
        expect(state.isEmpty, isFalse);
        expect(state.isSuccess, isFalse);
        expect(state.isError, isFalse);
      });

      test('should be equal to other loading states', () {
        final state1 = CubitState.loading();
        final state2 = CubitState.loading();

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('should not be equal to empty state', () {
        final loadingState = CubitState.loading();
        final emptyState = CubitState.empty();

        expect(loadingState, isNot(equals(emptyState)));
      });
    });

    group('SuccessCubitState with Tournament', () {
      test('should contain tournament data', () {
        final state = CubitState.success(value: mockTournament);
        expect(state.isSuccess, isTrue);
        expect(state.getSuccessValue<Tournament>(), equals(mockTournament));
      });

      test('should be equal when tournaments are equal', () {
        final state1 = CubitState.success(value: mockTournament);
        final state2 = CubitState.success(value: mockTournament);

        expect(state1, equals(state2));
      });

      test('should not be equal when tournaments are different', () {
        final differentTournament = Tournament(
          id: 'different_id',
          name: 'Different Tournament',
          date: mockDate,
          teams: [],
          matches: [],
          createdAt: mockCreatedAt,
        );

        final state1 = CubitState.success(value: mockTournament);
        final state2 = CubitState.success(value: differentTournament);

        expect(state1, isNot(equals(state2)));
      });

      test('should execute whenSuccess callback', () {
        final state = CubitState.success(value: mockTournament);
        Tournament? receivedTournament;
        
        state.whenSuccess<Tournament>((tournament) {
          receivedTournament = tournament;
        });
        
        expect(receivedTournament, equals(mockTournament));
      });
    });

    group('SuccessCubitState with Tournament List', () {
      test('should contain tournaments list', () {
        final state = CubitState.success(value: mockTournaments);
        expect(state.isSuccess, isTrue);
        expect(state.getSuccessValue<List<Tournament>>(), equals(mockTournaments));
      });

      test('should be equal when tournament lists are equal', () {
        final state1 = CubitState.success(value: mockTournaments);
        final state2 = CubitState.success(value: mockTournaments);

        expect(state1, equals(state2));
      });

      test('should not be equal when tournament lists are different', () {
        final differentTournaments = [mockTournament]; // Only one tournament

        final state1 = CubitState.success(value: mockTournaments);
        final state2 = CubitState.success(value: differentTournaments);

        expect(state1, isNot(equals(state2)));
      });

      test('should handle empty tournaments list', () {
        final emptyState1 = CubitState.success(value: <Tournament>[]);
        final emptyState2 = CubitState.success(value: <Tournament>[]);

        expect(emptyState1, equals(emptyState2));
        final tournaments = emptyState1.getSuccessValue<List<Tournament>>();
        expect(tournaments, isEmpty);
      });

      test('should work with CubitStateHelper', () {
        final state = CubitStateHelper.successList(mockTournaments);
        final tournaments = CubitStateHelper.getList<Tournament>(state);
        
        expect(tournaments, equals(mockTournaments));
        expect(CubitStateHelper.isListEmpty(state), isFalse);
      });
    });

    group('ErrorCubitState', () {
      test('should contain error message', () {
        const errorMessage = 'Something went wrong';
        final state = CubitState.error(message: errorMessage);

        expect(state.isError, isTrue);
        expect(state.getErrorMessage(), equals(errorMessage));
      });

      test('should be equal when error messages are equal', () {
        const errorMessage = 'Same error message';
        final state1 = CubitState.error(message: errorMessage);
        final state2 = CubitState.error(message: errorMessage);

        expect(state1, equals(state2));
      });

      test('should not be equal when error messages are different', () {
        final state1 = CubitState.error(message: 'Error 1');
        final state2 = CubitState.error(message: 'Error 2');

        expect(state1, isNot(equals(state2)));
      });

      test('should execute whenError callback', () {
        const errorMessage = 'Test error';
        final state = CubitState.error(message: errorMessage);
        String? receivedMessage;
        
        state.whenError((message) {
          receivedMessage = message;
        });
        
        expect(receivedMessage, equals(errorMessage));
      });
    });

    group('CubitState Pattern Matching', () {
      test('when method should execute correct branch', () {
        final emptyState = CubitState.empty();
        final loadingState = CubitState.loading();
        final successState = CubitState.success(value: mockTournament);
        final errorState = CubitState.error(message: 'Error message');
        
        // Test empty state
        final emptyResult = emptyState.when(
          empty: () => 'EMPTY',
          loading: () => 'LOADING',
          success: (_) => 'SUCCESS',
          error: (_) => 'ERROR',
        );
        expect(emptyResult, equals('EMPTY'));
        
        // Test loading state
        final loadingResult = loadingState.when(
          empty: () => 'EMPTY',
          loading: () => 'LOADING',
          success: (_) => 'SUCCESS',
          error: (_) => 'ERROR',
        );
        expect(loadingResult, equals('LOADING'));
        
        // Test success state
        final successResult = successState.when(
          empty: () => 'EMPTY',
          loading: () => 'LOADING',
          success: (value) => 'SUCCESS: ${value.runtimeType}',
          error: (_) => 'ERROR',
        );
        expect(successResult, equals('SUCCESS: Tournament'));
        
        // Test error state
        final errorResult = errorState.when(
          empty: () => 'EMPTY',
          loading: () => 'LOADING',
          success: (_) => 'SUCCESS',
          error: (msg) => 'ERROR: $msg',
        );
        expect(errorResult, equals('ERROR: Error message'));
      });
      
      test('maybeWhen method should handle orElse correctly', () {
        final successState = CubitState.success(value: mockTournament);
        
        final result = successState.maybeWhen(
          error: (msg) => 'ERROR: $msg',
          orElse: () => 'DEFAULT',
        );
        expect(result, equals('DEFAULT'));
      });
    });
    
    group('CubitState Helpers', () {
      test('CubitStateHelper should manage lists correctly', () {
        // Test empty list
        final emptyState = CubitStateHelper.emptyList<Tournament>();
        expect(CubitStateHelper.isListEmpty(emptyState), isTrue);
        expect(CubitStateHelper.getList<Tournament>(emptyState), isEmpty);
        
        // Test adding item to list
        final withOneItem = CubitStateHelper.updateListWithNewItem<Tournament>(emptyState, mockTournament);
        expect(CubitStateHelper.getList<Tournament>(withOneItem).length, equals(1));
        
        // Test removing item from list
        final backToEmpty = CubitStateHelper.removeItemFromList<Tournament>(
          withOneItem,
          (tournament) => tournament.id == mockTournament.id,
        );
        expect(CubitStateHelper.isListEmpty(backToEmpty), isTrue);
      });
    });
  });
}