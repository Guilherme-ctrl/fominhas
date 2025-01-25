import 'package:fominhas/features/treinos/data/datasource/treinos_datasource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fominhas/features/treinos/data/model/adicionar_treinos_model.dart';
import 'package:fominhas/features/treinos/data/model/editar_treino_model.dart';
import 'package:fominhas/features/treinos/data/model/treinos_model.dart';

class TreinosDatasourceImplementation implements ITreinosDatasource {
  @override
  Future<List<TreinosModel>> getTreinos() async {
    try {
      final treinosSnapshot = await FirebaseFirestore.instance.collection('treinos').get();
      List<TreinosModel> treinos = treinosSnapshot.docs.map((doc) {
        final data = doc.data();

        // Converte o documento para o modelo, incluindo o ID
        return TreinosModel.fromJson(doc.id, data);
      }).toList();

      return treinos;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<bool> adicionarTreino(AdicionarTreinosModel model) async {
    try {
      await FirebaseFirestore.instance.collection('treinos').add(model.toMap());

      return true;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<bool> editarTreino(EditarTreinoModel model, String id) async {
    try {
      await FirebaseFirestore.instance.collection('treinos').doc(id).update(model.toMap());

      return true;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<TreinosModel> getTreinoById(String id) async {
    try {
      final treinoDoc = await FirebaseFirestore.instance.collection('treinos').doc(id).get();

      return TreinosModel.fromJson(id, treinoDoc.data()!);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
