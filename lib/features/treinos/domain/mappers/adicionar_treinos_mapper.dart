import 'package:fominhas/features/treinos/data/model/adicionar_treinos_model.dart';
import 'package:fominhas/features/treinos/domain/entities/adicionar_treinos_entity.dart';

extension AdicionarTreinosMapper on AdicionarTreinosEntity {
  AdicionarTreinosModel toModel() => AdicionarTreinosModel(data: data, descricao: descricao);
}
