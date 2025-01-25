import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fominhas/core/data/datasource/jogadores/jogadores_datasource.dart';
import 'package:fominhas/core/data/models/jogadores/adicionar_jogadores_model.dart';
import 'package:fominhas/core/data/models/jogadores/jogadores_response_model.dart';

class JogadoresDatasourceImplementation implements IJogadoresDatasource {
  @override
  Future<bool> editarPresencas(String jogadorId, String tipo) async {
    try {
      await FirebaseFirestore.instance.collection('jogadores').doc(jogadorId).update({
        tipo: FieldValue.increment(1),
      });

      return true;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<JogadoresResponseModel>> getJogadores() async {
    try {
      final jogadoresSnapshot = await FirebaseFirestore.instance.collection('jogadores').get();
      List<JogadoresResponseModel> jogadores = jogadoresSnapshot.docs.map((doc) {
        final data = doc.data();

        // Converte o documento para o modelo, incluindo o ID
        return JogadoresResponseModel.fromJson(doc.id, data);
      }).toList();
      return jogadores;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<bool> adicionarJogadores(AdicionarJogadoresModel model) async {
    try {
      await FirebaseFirestore.instance.collection('jogadores').add(model.toMap());
      return true;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<JogadoresResponseModel> getJogadorById(String jogadorId) async {
    try {
      final jogadorDoc = await FirebaseFirestore.instance.collection('jogadores').doc(jogadorId).get();
      return JogadoresResponseModel.fromJson(jogadorId, jogadorDoc.data()!);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<bool> editarJogador(AdicionarJogadoresModel model, String jogadorId) async {
    try {
      await FirebaseFirestore.instance.collection('jogadores').doc(jogadorId).update(model.toMap());
      return true;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
