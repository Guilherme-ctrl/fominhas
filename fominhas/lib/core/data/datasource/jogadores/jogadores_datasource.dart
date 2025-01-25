import '../../models/jogadores/adicionar_jogadores_model.dart';
import '../../models/jogadores/jogadores_response_model.dart';

abstract class IJogadoresDatasource {
  Future<bool> editarPresencas(String jogadorId, String tipo);
  Future<List<JogadoresResponseModel>> getJogadores();
  Future<bool> adicionarJogadores(AdicionarJogadoresModel model);
  Future<JogadoresResponseModel> getJogadorById(String jogadorId);
  Future<bool> editarJogador(AdicionarJogadoresModel model, String jogadorId);
}
