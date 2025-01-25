import 'package:fominhas/core/data/models/jogadores/jogadores_response_model.dart';
import 'package:fominhas/core/domain/entities/jogadores/jogadores_response_entity.dart';

extension JogadoresMapper on JogadoresResponseModel {
  JogadoresResponseEntity toEntity() =>
      JogadoresResponseEntity(id: id, nome: nome, presencas: presencas, faltas: faltas, email: email, documento: documento, numero: numero);
}

extension ListJogadoresMapper on List<JogadoresResponseModel> {
  List<JogadoresResponseEntity> toEntityList() => map((e) => e.toEntity()).toList();
}
