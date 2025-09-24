import 'package:equatable/equatable.dart';

import '../../cast/try_cast.dart';

class DataFailureModel extends Equatable {
  final String? error;
  final String message;

  const DataFailureModel({this.error = "", this.message = "Ocorreu um erro"});

  factory DataFailureModel.fromMap(Map<String, dynamic> map) {
    return DataFailureModel(
      error: tryCast(map["error"], ""),
      message: tryCast(map["message"], "Ocorreu um erro"),
    );
  }

  static List<DataFailureModel> fromListMap(List<Map<String, dynamic>> maps) =>
      maps.map((e) => DataFailureModel.fromMap(e)).toList();

  Map<String, dynamic> toMap() {
    return {
      'error': error,
      'message': message,
    };
  }

  @override
  List<Object?> get props => [error, message];

  @override
  String toString() => 'DataFailureModel(error: $error, message: $message)';
}
