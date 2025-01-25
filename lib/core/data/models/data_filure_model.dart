import 'package:equatable/equatable.dart';

import '../../cast/try_cast.dart';

class DataFailureModel extends Equatable{
  final String? error;
  final String message;

  DataFailureModel({ this.error = "",  this.message = "Ocorreu um erro"});

  factory DataFailureModel.fromMap(Map<String, dynamic> map) {
    return DataFailureModel(error: tryCast(map["error"], ""), message: tryCast(map["message"], "Ocorreu um erro"));
  }

  static List<DataFailureModel> fromListMap(List maps) => maps.map((e) => DataFailureModel.fromMap(e)).toList();
  
  @override
  List<Object?> get props => [error, message];
}