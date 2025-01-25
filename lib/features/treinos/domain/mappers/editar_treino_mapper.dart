import 'package:fominhas/features/treinos/data/model/editar_treino_model.dart';
import 'package:fominhas/features/treinos/domain/entities/editar_treino_entity.dart';

extension EditarTreinoMapper on EditarTreinoEntity {
  EditarTreinoModel toModel() => EditarTreinoModel(descricao: descricao, data: data, presentes: presentes);
}
