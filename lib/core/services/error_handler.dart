import 'dart:io';

import '../errors/failure.dart';
import '../state/cubit_state.dart';
import 'logging_service.dart';

/// Service estático para centralizar o tratamento de erros na aplicação
class ErrorHandler {
  /// Trata uma falha, loga no Firebase e retorna estado de erro para UI
  static CubitState handleFailure(
    Failure failure, {
    required String context,
  }) {
    // Loga o erro no Firebase automaticamente
    logFailure(failure, context: context);

    // Retorna estado de erro com mensagem padronizada
    final message = getErrorMessage(failure);
    return CubitState.error(message: message);
  }

  /// Trata exceção genérica, converte em Failure e processa
  static CubitState handleException(
    Object exception, {
    required String context,
    StackTrace? stackTrace,
  }) {
    // Converte exceção em Failure apropriada
    final failure = _convertExceptionToFailure(exception, stackTrace);
    
    // Processa através do handleFailure
    return handleFailure(failure, context: context);
  }

  /// Retorna apenas a mensagem de erro sem criar estado
  static String getErrorMessage(Failure failure) {
    return switch (failure) {
      DataPostFailure() => failure.message,
      ServerFailure() => failure.message,
      NetworkFailure() => failure.message,
      AuthenticationFailure() => failure.message,
      ValidationFailure() => failure.message,
      UnknownFailure() => failure.message,
      _ => 'Ocorreu um erro inesperado. Tente novamente.',
    };
  }

  /// Loga erro no Firebase sem criar estado
  static void logFailure(
    Failure failure, {
    required String context,
  }) {
    try {
      // Estrutura padrão de log de erro
      final errorData = {
        'context': context,
        'failure_type': failure.runtimeType.toString(),
        'failure_message': failure.toString(),
        'timestamp': DateTime.now().toIso8601String(),
        'platform': Platform.isAndroid ? 'android' : 'ios',
      };

      // Log usando LoggingService estático
      LoggingService.error(
        context,
        exception: failure,
        data: errorData,
      );
    } catch (loggingException) {
      // Fallback silencioso - não queremos que erro de log quebre a app
      // ignore: avoid_print
      print('Erro ao fazer log: $loggingException');
    }
  }

  /// Converte exceções genéricas em Failures apropriadas
  static Failure _convertExceptionToFailure(Object exception, StackTrace? stackTrace) {
    if (exception is Failure) return exception;

    if (exception is SocketException) {
      return NetworkFailure(
        message: 'Erro de conexão. Verifique sua internet e tente novamente.',
      );
    }

    if (exception.toString().toLowerCase().contains('timeout')) {
      return NetworkFailure(
        message: 'Tempo limite esgotado. Verifique sua conexão.',
      );
    }

    if (exception is FormatException) {
      return UnknownFailure(
        message: 'Erro ao processar dados. Tente novamente.',
        originalError: exception,
      );
    }

    return UnknownFailure(
      message: 'Erro inesperado. Tente novamente.',
      originalError: exception,
    );
  }
}
