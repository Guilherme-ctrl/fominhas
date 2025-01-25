import 'package:fominhas/features/treinos/data/model/treinos_model.dart';
import 'package:fominhas/features/treinos/domain/entities/treinos_entity.dart';

extension TreinosMapper on TreinosModel {
  TreinosEntity toEntity() => TreinosEntity(data: data, descricao: descricao, presenca: presenca, id: id);
}

extension ListTreinosMapper on List<TreinosModel> {
  List<TreinosEntity> toEntityList() => map((e) => e.toEntity()).toList();
}
