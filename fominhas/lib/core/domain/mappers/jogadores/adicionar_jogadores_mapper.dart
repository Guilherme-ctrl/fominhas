import 'package:fominhas/core/data/models/jogadores/adicionar_jogadores_model.dart';
import 'package:fominhas/core/domain/entities/jogadores/adicionar_jogadores_entity.dart';

extension EditarJogadoresMapper on AdicionarJogadoresEntity {
  AdicionarJogadoresModel toModel() => AdicionarJogadoresModel(nome: nome, numero: numero, email: email, documento: documento);
}
