import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/state/cubit_state.dart';
import '../../../../core/extensions/cubit_state_extensions.dart';
import '../../../../core/services/error_handler.dart';
import '../../domain/entities/match.dart';
import '../../domain/repositories/matches_repository.dart';

class MatchesCubit extends Cubit<CubitState> with CubitLoggingMixin {
  final IMatchesRepository _repository;

  MatchesCubit(this._repository) : super(CubitState.empty());

  Future<void> loadMatches() async {
    logOperation('loadMatches');
    emit(CubitState.loading());

    final result = await _repository.getAllMatches();
    final state = result.fold(
      (failure) {
        logError('loadMatches', failure);
        return ErrorHandler.handleFailure(failure, context: 'MatchesCubit.loadMatches');
      },
      (matches) {
        // Log removido
        return CubitStateHelper.successList(matches);
      },
    );

    emit(state);
  }

  Future<void> createMatch(Match match) async {
    logOperation('createMatch', data: {'matchId': match.id});

    final result = await _repository.createMatch(match);
    result.fold(
      (failure) {
        logError('createMatch', failure);
        emit(ErrorHandler.handleFailure(failure, context: 'MatchesCubit.createMatch'));
      },
      (createdMatch) {
        if (state.isSuccess) {
          // Adicionar no início da lista para mostrar partidas mais recentes primeiro
          final currentList = CubitStateHelper.getList<Match>(state);
          final updatedList = [createdMatch, ...currentList];
          emit(CubitStateHelper.successList(updatedList));
        } else {
          loadMatches();
        }

        // Log removido
      },
    );
  }

  Future<void> updateMatch(Match match) async {
    logOperation('updateMatch', data: {'matchId': match.id});

    final result = await _repository.updateMatch(match);
    result.fold(
      (failure) {
        logError('updateMatch', failure);
        emit(ErrorHandler.handleFailure(failure, context: 'MatchesCubit.updateMatch'));
      },
      (updatedMatch) {
        if (state.isSuccess) {
          final updatedState = CubitStateHelper.updateItemInList<Match>(state, (m) => m.id == updatedMatch.id, (m) => updatedMatch);
          emit(updatedState);
        }

        // Log removido
      },
    );
  }

  Future<void> deleteMatch(String id) async {
    logOperation('deleteMatch', data: {'matchId': id});

    final result = await _repository.deleteMatch(id);
    result.fold(
      (failure) {
        logError('deleteMatch', failure);
        emit(ErrorHandler.handleFailure(failure, context: 'MatchesCubit.deleteMatch'));
      },
      (_) {
        if (state.isSuccess) {
          final updatedState = CubitStateHelper.removeItemFromList<Match>(state, (match) => match.id == id);
          emit(updatedState);
        }

        // Log removido
      },
    );
  }

  Future<Match?> getMatchById(String id) async {
    logOperation('getMatchById', data: {'matchId': id});

    final result = await _repository.getMatchById(id);
    return result.fold(
      (failure) {
        logError('getMatchById', failure);
        emit(ErrorHandler.handleFailure(failure, context: 'MatchesCubit.getMatchById'));
        return null;
      },
      (match) {
        // Log removido
        return match;
      },
    );
  }

}

// Estados customizados foram removidos em favor do CubitState padrão
// Para acessar dados:
// - Lista de Matches: CubitStateHelper.getList<Match>(state)
// - Verificar estados: state.isLoading, state.isError, state.isSuccess
// - Obter erro: state.getErrorMessage()
