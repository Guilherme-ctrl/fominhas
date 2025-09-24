import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/state/cubit_state.dart';
import '../../../../core/extensions/cubit_state_extensions.dart';
import '../../../../core/services/error_handler.dart';
import '../../domain/entities/player.dart';
import '../../domain/repositories/players_repository.dart';

class PlayersCubit extends Cubit<CubitState> with CubitLoggingMixin {
  final IPlayersRepository _repository;

  PlayersCubit(this._repository) : super(CubitState.empty());

  Future<void> loadPlayers() async {
    logOperation('loadPlayers');
    emit(CubitState.loading());

    final result = await _repository.getAllPlayers();
    result.fold(
      (failure) {
        logError('loadPlayers', failure);
        emit(ErrorHandler.handleFailure(failure, context: 'PlayersCubit.loadPlayers'));
      },
      (players) {
        // Log removido para evitar Firebase nos testes
        emit(CubitStateHelper.successList(players));
      },
    );
  }

  Future<void> createPlayer(Player player) async {
    logOperation('createPlayer', data: {'playerName': player.name});

    final result = await _repository.createPlayer(player);
    result.fold(
      (failure) {
        logError('createPlayer', failure);
        emit(ErrorHandler.handleFailure(failure, context: 'PlayersCubit.createPlayer'));
      },
      (createdPlayer) {
        if (state.isSuccess) {
          final updatedState = CubitStateHelper.updateListWithNewItem<Player>(state, createdPlayer);
          emit(updatedState);
        } else {
          loadPlayers();
        }

        // Log removido
      },
    );
  }

  Future<void> updatePlayer(Player player) async {
    logOperation('updatePlayer', data: {'playerId': player.id, 'playerName': player.name});

    final result = await _repository.updatePlayer(player);
    result.fold(
      (failure) {
        logError('updatePlayer', failure);
        emit(ErrorHandler.handleFailure(failure, context: 'PlayersCubit.updatePlayer'));
      },
      (updatedPlayer) {
        if (state.isSuccess) {
          final updatedState = CubitStateHelper.updateItemInList<Player>(state, (p) => p.id == updatedPlayer.id, (p) => updatedPlayer);
          emit(updatedState);
        }

        // Log removido
      },
    );
  }

  Future<void> deletePlayer(String id) async {
    logOperation('deletePlayer', data: {'playerId': id});

    final result = await _repository.deletePlayer(id);
    result.fold(
      (failure) {
        logError('deletePlayer', failure);
        emit(ErrorHandler.handleFailure(failure, context: 'PlayersCubit.deletePlayer'));
      },
      (_) {
        if (state.isSuccess) {
          final updatedState = CubitStateHelper.removeItemFromList<Player>(state, (player) => player.id == id);
          emit(updatedState);
        }

        // Log removido
      },
    );
  }

  Future<void> searchPlayers(String query) async {
    logOperation('searchPlayers', data: {'query': query});

    if (query.isEmpty) {
      await loadPlayers();
      return;
    }

    emit(CubitState.loading());

    final result = await _repository.searchPlayers(query);
    result.fold(
      (failure) {
        logError('searchPlayers', failure);
        emit(ErrorHandler.handleFailure(failure, context: 'PlayersCubit.searchPlayers'));
      },
      (players) {
        // Log removido
        emit(CubitStateHelper.successList(players));
      },
    );
  }

}

// Estados customizados foram removidos em favor do CubitState padrão
// Para acessar dados:
// - Lista de Players: CubitStateHelper.getList<Player>(state)
// - Verificar estados: state.isLoading, state.isError, state.isSuccess
// - Obter erro: state.getErrorMessage()
