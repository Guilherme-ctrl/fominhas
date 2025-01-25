import 'package:equatable/equatable.dart';
import '../data/models/data_filure_model.dart';

abstract class Failure extends Equatable {}

class DataPostFailure extends Failure {
  final String message;
  final String statusCode;
  final List<DataFailureModel> listError;

  DataPostFailure( {this.statusCode = "", this.listError = const [], this.message = "Ocorreu um erro, tente novamente"});

  @override
  List<Object?> get props => [message, statusCode, listError];
}
