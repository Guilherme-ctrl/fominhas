import '../state/cubit_state.dart';

/// Extensões para facilitar o uso do CubitState
extension CubitStateExtensions on CubitState {
  /// Verifica se o estado é vazio
  bool get isEmpty => this is EmptyCubitState;

  /// Verifica se o estado está carregando
  bool get isLoading => this is LoadingCubitState;

  /// Verifica se o estado teve sucesso
  bool get isSuccess => this is SuccessCubitState;

  /// Verifica se o estado tem erro
  bool get isError => this is ErrorCubitState;

  /// Obtém o valor de sucesso de forma segura
  T? getSuccessValue<T>() {
    if (this is SuccessCubitState) {
      final value = (this as SuccessCubitState).value;
      if (value is T) {
        return value;
      }
    }
    return null;
  }

  /// Obtém a mensagem de erro de forma segura
  String? getErrorMessage() {
    if (this is ErrorCubitState) {
      return (this as ErrorCubitState).message;
    }
    return null;
  }

  /// Executa callback quando o estado for success
  void whenSuccess<T>(void Function(T value) callback) {
    if (this is SuccessCubitState) {
      final value = (this as SuccessCubitState).value;
      if (value is T) {
        callback(value);
      }
    }
  }

  /// Executa callback quando o estado for error
  void whenError(void Function(String message) callback) {
    if (this is ErrorCubitState) {
      callback((this as ErrorCubitState).message);
    }
  }

  /// Executa callback quando o estado for loading
  void whenLoading(void Function() callback) {
    if (this is LoadingCubitState) {
      callback();
    }
  }

  /// Executa callback quando o estado for empty
  void whenEmpty(void Function() callback) {
    if (this is EmptyCubitState) {
      callback();
    }
  }

  /// Pattern matching para CubitState
  R when<R>({
    required R Function() empty,
    required R Function() loading,
    required R Function(dynamic value) success,
    required R Function(String message) error,
  }) {
    if (this is EmptyCubitState) {
      return empty();
    } else if (this is LoadingCubitState) {
      return loading();
    } else if (this is SuccessCubitState) {
      return success((this as SuccessCubitState).value);
    } else if (this is ErrorCubitState) {
      return error((this as ErrorCubitState).message);
    }
    throw UnimplementedError('Estado não reconhecido: $runtimeType');
  }

  /// Pattern matching com fallback padrão
  R maybeWhen<R>({
    R Function()? empty,
    R Function()? loading,
    R Function(dynamic value)? success,
    R Function(String message)? error,
    required R Function() orElse,
  }) {
    if (this is EmptyCubitState && empty != null) {
      return empty();
    } else if (this is LoadingCubitState && loading != null) {
      return loading();
    } else if (this is SuccessCubitState && success != null) {
      return success((this as SuccessCubitState).value);
    } else if (this is ErrorCubitState && error != null) {
      return error((this as ErrorCubitState).message);
    }
    return orElse();
  }
}

/// Classe helper para criar estados de forma mais conveniente
class CubitStateHelper {
  /// Cria estado de lista vazia
  static CubitState emptyList<T>() => CubitState.success(value: <T>[]);

  /// Cria estado de sucesso com lista
  static CubitState successList<T>(List<T> list) => CubitState.success(value: list);

  /// Cria estado de erro para operações CRUD
  static CubitState crudError(String operation, String message) {
    return CubitState.error(message: 'Erro ao $operation: $message');
  }

  /// Cria estado de sucesso para operações CRUD
  static CubitState crudSuccess<T>(String operation, T value) {
    return CubitState.success(value: value);
  }

  /// Verifica se a lista no estado está vazia
  static bool isListEmpty(CubitState state) {
    if (state.isSuccess) {
      final value = state.getSuccessValue();
      if (value is List) {
        return value.isEmpty;
      }
    }
    return true;
  }

  /// Obtém lista do estado de forma segura
  static List<T> getList<T>(CubitState state) {
    if (state.isSuccess) {
      final value = state.getSuccessValue();
      if (value is List<T>) {
        return value;
      }
    }
    return <T>[];
  }

  /// Atualiza lista no estado com novo item
  static CubitState updateListWithNewItem<T>(CubitState currentState, T newItem) {
    final currentList = getList<T>(currentState);
    final updatedList = [...currentList, newItem];
    return successList(updatedList);
  }

  /// Remove item da lista no estado
  static CubitState removeItemFromList<T>(
    CubitState currentState,
    bool Function(T item) predicate,
  ) {
    final currentList = getList<T>(currentState);
    final updatedList = currentList.where((item) => !predicate(item)).toList();
    return successList(updatedList);
  }

  /// Atualiza item específico na lista
  static CubitState updateItemInList<T>(
    CubitState currentState,
    bool Function(T item) finder,
    T Function(T item) updater,
  ) {
    final currentList = getList<T>(currentState);
    final updatedList = currentList.map((item) {
      if (finder(item)) {
        return updater(item);
      }
      return item;
    }).toList();
    return successList(updatedList);
  }
}

/// Mixin para adicionar logging estruturado aos cubits
mixin CubitLoggingMixin<T extends CubitState> {
  String get cubitName => runtimeType.toString();

  void logStateChange(T previousState, T newState, {Map<String, dynamic>? context}) {
    // Importar LoggingService quando necessário
    try {
      // LoggingService.info(
      //   'Estado alterado em $cubitName: ${previousState.runtimeType} -> ${newState.runtimeType}',
      //   data: {
      //     'cubit': cubitName,
      //     'previous_state': previousState.runtimeType.toString(),
      //     'new_state': newState.runtimeType.toString(),
      //     if (context != null) 'context': context,
      //   },
      // );
    } catch (e) {
      // Fallback silencioso para evitar quebrar os cubits
    }
  }

  void logError(String operation, Object error, {StackTrace? stackTrace}) {
    try {
      // LoggingService.error(
      //   'Erro em $cubitName durante $operation',
      //   exception: error,
      //   stackTrace: stackTrace,
      //   data: {
      //     'cubit': cubitName,
      //     'operation': operation,
      //   },
      // );
    } catch (e) {
      // Fallback silencioso
    }
  }

  void logOperation(String operation, {Map<String, dynamic>? data}) {
    try {
      // LoggingService.info(
      //   'Operação $operation iniciada em $cubitName',
      //   data: {
      //     'cubit': cubitName,
      //     'operation': operation,
      //     if (data != null) ...data,
      //   },
      // );
    } catch (e) {
      // Fallback silencioso
    }
  }
}
