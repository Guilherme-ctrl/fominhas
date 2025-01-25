import 'package:fominhas/features/treinos/data/model/treinos_model.dart';

import '../model/adicionar_treinos_model.dart';
import '../model/editar_treino_model.dart';

abstract class ITreinosDatasource {
  Future<List<TreinosModel>> getTreinos();
  Future<bool> adicionarTreino(AdicionarTreinosModel model);
  Future<bool> editarTreino(EditarTreinoModel model, String id);
  Future<TreinosModel> getTreinoById(String id);
}
