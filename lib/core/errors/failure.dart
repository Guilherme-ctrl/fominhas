import 'package:equatable/equatable.dart';
import '../data/models/data_filure_model.dart';

abstract class Failure extends Equatable {
  const Failure();
}

// Failure para erros de API/Network
class ServerFailure extends Failure {
  final String message;
  final int? statusCode;
  final List<DataFailureModel> errors;

  const ServerFailure({
    this.message = "Erro no servidor, tente novamente",
    this.statusCode,
    this.errors = const [],
  });

  @override
  List<Object?> get props => [message, statusCode, errors];

  @override
  String toString() => 'ServerFailure(message: $message, statusCode: $statusCode)';
}

// Failure para erros de conexão
class NetworkFailure extends Failure {
  final String message;

  const NetworkFailure({this.message = "Erro de conexão. Verifique sua internet."});

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'NetworkFailure(message: $message)';
}

// Failure para erros de autenticação
class AuthenticationFailure extends Failure {
  final String message;

  const AuthenticationFailure({this.message = "Erro de autenticação"});

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'AuthenticationFailure(message: $message)';
}

// Failure para validação local
class ValidationFailure extends Failure {
  final String message;
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    this.message = "Dados inválidos",
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, fieldErrors];

  @override
  String toString() => 'ValidationFailure(message: $message, fieldErrors: $fieldErrors)';
}

// Failure genérico
class UnknownFailure extends Failure {
  final String message;
  final dynamic originalError;

  const UnknownFailure({
    this.message = "Erro desconhecido, tente novamente",
    this.originalError,
  });

  @override
  List<Object?> get props => [message, originalError];

  @override
  String toString() => 'UnknownFailure(message: $message, originalError: $originalError)';
}

// Manter compatibilidade com o nome anterior
class DataPostFailure extends ServerFailure {
  const DataPostFailure({
    super.message = "Ocorreu um erro, tente novamente",
    super.statusCode,
    super.errors = const [],
  });
}
