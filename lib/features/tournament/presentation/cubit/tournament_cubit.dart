import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/state/cubit_state.dart';
import '../../../../core/extensions/cubit_state_extensions.dart';
import '../../../../core/services/error_handler.dart';
import '../../domain/entities/tournament.dart';
import '../../domain/repositories/tournament_repository.dart';
import '../../domain/services/tournament_service.dart';

class TournamentCubit extends Cubit<CubitState> with CubitLoggingMixin {
  final ITournamentRepository _repository;
  Tournament? _currentTournament;

  TournamentCubit(this._repository) : super(CubitState.empty());

  Future<void> loadTournaments() async {
    logOperation('loadTournaments');
    emit(CubitState.loading());

    final result = await _repository.getAllTournaments();
    result.fold(
      (failure) {
        logError('loadTournaments', failure);
        emit(ErrorHandler.handleFailure(failure, context: 'TournamentCubit.loadTournaments'));
      },
      (tournaments) {
        // Log através do mixin para evitar dependência direta do Firebase
        // LoggingService.logTournamentEvent('multiple', 'tournaments_loaded', {'count': tournaments.length});
        emit(CubitStateHelper.successList(tournaments));
      },
    );
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
        emit(ErrorHandler.handleFailure(failure, context: 'TournamentCubit.loadCurrentTournament'));
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

        // Log através do mixin
        // LoggingService.logTournamentEvent(...);
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
        emit(ErrorHandler.handleFailure(failure, context: 'TournamentCubit.loadTournament'));
      },
      (tournament) {
        if (tournament != null) {
          _currentTournament = tournament;
          emit(CubitState.success(value: tournament));

          // Log através do mixin
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
        emit(ErrorHandler.handleFailure(failure, context: 'TournamentCubit.createTournament'));
      },
      (createdTournament) {
        _currentTournament = createdTournament;
        emit(CubitState.success(value: createdTournament));

        // Log através do mixin
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
        emit(ErrorHandler.handleFailure(failure, context: 'TournamentCubit.updateTournament'));
      },
      (result) {
        _currentTournament = result;
        
        // Se o estado atual é uma lista de torneios, atualizar o item na lista
        if (state.isSuccess) {
          try {
            final currentTournaments = CubitStateHelper.getList<Tournament>(state);
            if (currentTournaments.isNotEmpty) {
              // Encontrar e atualizar o torneio na lista
              final updatedTournaments = currentTournaments.map((t) {
                return t.id == result.id ? result : t;
              }).toList();
              
              emit(CubitStateHelper.successList(updatedTournaments));
              return;
            }
          } catch (e) {
            // Se não conseguiu tratar como lista, continua com single value
          }
        }
        
        // Fallback: emitir como valor único se não era uma lista
        emit(CubitState.success(value: result));
        
        // Log através do mixin
      },
    );
  }

  Future<void> deleteTournament(String tournamentId) async {
    logOperation('deleteTournament', data: {'tournamentId': tournamentId});

    final result = await _repository.deleteTournament(tournamentId);
    result.fold(
      (failure) {
        logError('deleteTournament', failure);
        emit(ErrorHandler.handleFailure(failure, context: 'TournamentCubit.deleteTournament'));
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

        // Log através do mixin
      },
    );
  }


  // Getter para o torneio atual
  Tournament? get currentTournament => _currentTournament;
}

// Estados customizados foram removidos em favor do CubitState padrão
// Para acessar dados:
// - Tournament único: state.getSuccessValue<Tournament>()
// - Lista de Tournaments: CubitStateHelper.getList<Tournament>(state)
// - Verificar estados: state.isLoading, state.isError, state.isSuccess
// - Obter erro: state.getErrorMessage()
