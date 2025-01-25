import 'package:equatable/equatable.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:fominhas/core/utils/converters/date_converter.dart';

import '../../../../core/cast/try_cast.dart';

class TreinosModel extends Equatable {
  final String id;
  final String data;
  final String descricao;
  final List<dynamic> presenca;

  TreinosModel({required this.data, required this.descricao, required this.presenca, required this.id});

  factory TreinosModel.fromJson(String id, Map<String, dynamic> json) {
    return TreinosModel(
      id: id,
      data: Modular.get<IDateConverter>().formatterDiaMesAno(tryCast<String>(json['data'], "")),
      descricao: tryCast<String>(json['descricao'], ""),
      presenca: json['presencas'],
    );
  }

  @override
  List<Object?> get props => [id, data, descricao, presenca];
}
