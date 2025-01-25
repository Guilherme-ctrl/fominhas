import 'package:dartz/dartz.dart';
import 'package:fominhas/core/errors/failure.dart';

import '../../entities/jogadores/adicionar_jogadores_entity.dart';
import '../../entities/jogadores/jogadores_response_entity.dart';

abstract class IJogadoresRepository {
  Future<Either<Failure, bool>> editarPresencas(String jogadorId, String tipo);
  Future<Either<Failure, List<JogadoresResponseEntity>>> getJogadores();
  Future<Either<Failure, bool>> adicionarJogadores(AdicionarJogadoresEntity entity);
  Future<Either<Failure, JogadoresResponseEntity>> getJogadorById(String jogadorId);
  Future<Either<Failure, bool>> editarJogador(AdicionarJogadoresEntity entity, String jogadorId);
}
