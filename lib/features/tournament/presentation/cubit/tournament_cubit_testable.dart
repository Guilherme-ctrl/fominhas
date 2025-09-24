import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/state/cubit_state.dart';
import '../../../../core/extensions/cubit_state_extensions.dart';
import '../../../../core/services/mock_logging_service.dart' as mock_logging;
import '../../../../core/errors/failure.dart';
import '../../domain/entities/tournament.dart';
import '../../domain/repositories/tournament_repository.dart';
import '../../domain/services/tournament_service.dart';

/// Versão testável do TournamentCubit que usa MockLoggingService
/// Esta classe deve ser usada APENAS em testes unitários
class TestableTournamentCubit extends Cubit<CubitState> with CubitLoggingMixin {
  final ITournamentRepository _repository;
  Tournament? _currentTournament;

  TestableTournamentCubit(this._repository) : super(CubitState.empty());

  Future<void> loadTournaments() async {
    logOperation('loadTournaments');
    emit(CubitState.loading());

    final result = await _repository.getAllTournaments();
    final state = result.fold(
      (failure) {
        logError('loadTournaments', failure);
        _logFailure('tournaments_load_failed', failure);
        return _getErrorState(failure);
      },
      (tournaments) {
        mock_logging.MockLoggingService.logTournamentEvent('multiple', 'tournaments_loaded', {'count': tournaments.length});
        return CubitStateHelper.successList(tournaments);
      },
    );

    emit(state);
  }

  Future<void> loadCurrentTournament() async {
    logOperation('loadCurrentTournament');
    emit(CubitState.loading());

    if (_currentTournament != null) {
      emit(CubitState.success(value: _currentTournament!));
      return;
    }

    final result = await _repository.getAllTournaments();
    result.fold(
      (failure) {
        logError('loadCurrentTournament', failure);
        _logFailure('current_tournament_load_failed', failure);
        emit(_getErrorState(failure));
      },
      (tournaments) {
        if (tournaments.isEmpty) {
          emit(CubitState.error(message: 'Nenhum torneio encontrado'));
          return;
        }

        // Priorizar torneios em andamento
        final inProgressTournaments = tournaments.where((t) => t.status == TournamentStatus.inProgress).toList();

        Tournament currentTournament;
        if (inProgressTournaments.isNotEmpty) {
          currentTournament = inProgressTournaments.first;
        } else {
          // Se não há torneios em andamento, pegar o mais recente
          final sortedTournaments = List<Tournament>.from(tournaments);
          sortedTournaments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          currentTournament = sortedTournaments.first;
        }

        _currentTournament = currentTournament;
        emit(CubitState.success(value: currentTournament));

        mock_logging.MockLoggingService.logTournamentEvent(currentTournament.id ?? 'unknown', 'tournament_loaded_as_current', {
          'tournament_name': currentTournament.name,
          'status': currentTournament.status.name,
        });
      },
    );
  }

  Future<void> loadTournament(String tournamentId) async {
    logOperation('loadTournament', data: {'tournamentId': tournamentId});
    emit(CubitState.loading());

    final result = await _repository.getTournament(tournamentId);
    result.fold(
      (failure) {
        logError('loadTournament', failure);
        _logFailure('tournament_load_by_id_failed', failure, {'tournamentId': tournamentId});
        emit(_getErrorState(failure));
      },
      (tournament) {
        if (tournament != null) {
          _currentTournament = tournament;
          emit(CubitState.success(value: tournament));

          mock_logging.MockLoggingService.logTournamentEvent(tournamentId, 'tournament_loaded_by_id', {'tournament_name': tournament.name});
        } else {
          emit(CubitState.error(message: 'Torneio não encontrado'));
        }
      },
    );
  }

  Future<void> createTournament({
    required String name,
    required DateTime date,
    required List<TournamentTeam> teams,
    required List<TournamentMatch> matches,
  }) async {
    logOperation('createTournament', data: {'name': name, 'teamsCount': teams.length});
    emit(CubitState.loading());

    // Aplicar cores padrão aos times
    final teamsWithColors = TournamentService.updateTeamColorsAndNames(teams);

    final tournament = Tournament(
      name: name,
      date: date,
      teams: teamsWithColors,
      matches: matches,
      status: TournamentStatus.inProgress,
      createdAt: DateTime.now(),
    );

    final result = await _repository.createTournament(tournament);
    result.fold(
      (failure) {
        logError('createTournament', failure);
        _logFailure('tournament_create_failed', failure, {'name': name});
        emit(_getErrorState(failure));
      },
      (createdTournament) {
        _currentTournament = createdTournament;
        emit(CubitState.success(value: createdTournament));

        mock_logging.MockLoggingService.logTournamentEvent(createdTournament.id ?? 'unknown', 'tournament_created', {
          'tournament_name': name,
          'teams_count': teamsWithColors.length,
          'matches_count': matches.length,
        });
      },
    );
  }

  Future<void> updateTournament(Tournament tournament) async {
    logOperation('updateTournament', data: {'tournamentId': tournament.id});

    final updatedTournament = tournament.copyWith(updatedAt: DateTime.now());

    final result = await _repository.updateTournament(updatedTournament);
    result.fold(
      (failure) {
        logError('updateTournament', failure);
        _logFailure('tournament_update_failed', failure, {'tournamentId': tournament.id});
        emit(_getErrorState(failure));
      },
      (result) {
        _currentTournament = result;
        emit(CubitState.success(value: result));

        mock_logging.MockLoggingService.logTournamentEvent(tournament.id ?? 'unknown', 'tournament_updated', {'tournament_name': result.name});
      },
    );
  }

  Future<void> deleteTournament(String tournamentId) async {
    logOperation('deleteTournament', data: {'tournamentId': tournamentId});

    final result = await _repository.deleteTournament(tournamentId);
    result.fold(
      (failure) {
        logError('deleteTournament', failure);
        _logFailure('tournament_delete_failed', failure, {'tournamentId': tournamentId});
        emit(_getErrorState(failure));
      },
      (_) {
        // Se o estado atual é uma lista de torneios, atualizar removendo o item
        if (state.isSuccess) {
          final currentTournaments = CubitStateHelper.getList<Tournament>(state);
          if (currentTournaments.isNotEmpty) {
            final updatedState = CubitStateHelper.removeItemFromList<Tournament>(state, (tournament) => tournament.id == tournamentId);
            emit(updatedState);
          }
        } else {
          loadTournaments();
        }

        mock_logging.MockLoggingService.logTournamentEvent(tournamentId, 'tournament_deleted', {});
      },
    );
  }

  CubitState _getErrorState(Failure failure) {
    final message = switch (failure) {
      DataPostFailure() => failure.message,
      ServerFailure() => failure.message,
      NetworkFailure() => failure.message,
      AuthenticationFailure() => failure.message,
      ValidationFailure() => failure.message,
      UnknownFailure() => failure.message,
      _ => 'Ocorreu um erro inesperado',
    };
    return CubitState.error(message: message);
  }

  void _logFailure(String event, Failure failure, [Map<String, dynamic>? extra]) {
    mock_logging.MockLoggingService.logStructuredData(event, {
      'failure_type': failure.runtimeType.toString(),
      'message': failure.toString(),
      ...?extra,
    });
  }

  // Getter para o torneio atual
  Tournament? get currentTournament => _currentTournament;
}
