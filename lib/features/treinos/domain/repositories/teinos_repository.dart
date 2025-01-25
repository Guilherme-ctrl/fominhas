import 'package:dartz/dartz.dart';
import 'package:fominhas/core/errors/failure.dart';

import '../entities/adicionar_treinos_entity.dart';
import '../entities/editar_treino_entity.dart';
import '../entities/treinos_entity.dart';

abstract class ITreinosRepository {
  Future<Either<Failure, List<TreinosEntity>>> getTreinos();
  Future<Either<Failure, bool>> adicionarTreinos(AdicionarTreinosEntity entity);
  Future<Either<Failure, bool>> editarTreino(EditarTreinoEntity entity, String id);
  Future<Either<Failure, TreinosEntity>> getTreinoById(String id);
}
