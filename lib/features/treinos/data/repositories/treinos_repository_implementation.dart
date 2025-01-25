import 'package:dartz/dartz.dart';
import 'package:fominhas/core/errors/failure.dart';
import 'package:fominhas/features/treinos/data/datasource/treinos_datasource.dart';
import 'package:fominhas/features/treinos/domain/entities/adicionar_treinos_entity.dart';
import 'package:fominhas/features/treinos/domain/entities/editar_treino_entity.dart';
import 'package:fominhas/features/treinos/domain/mappers/adicionar_treinos_mapper.dart';
import 'package:fominhas/features/treinos/domain/mappers/editar_treino_mapper.dart';
import 'package:fominhas/features/treinos/domain/mappers/treinos_mapper.dart';
import 'package:fominhas/features/treinos/domain/repositories/teinos_repository.dart';

import '../../domain/entities/treinos_entity.dart';

class TreinosRepositoryImplementation implements ITreinosRepository {
  final ITreinosDatasource datasource;

  TreinosRepositoryImplementation(this.datasource);
  @override
  Future<Either<Failure, List<TreinosEntity>>> getTreinos() async {
    try {
      final result = await datasource.getTreinos();
      return Right(result.toEntityList());
    } on DataPostFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(DataPostFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> adicionarTreinos(AdicionarTreinosEntity entity) async {
    try {
      final result = await datasource.adicionarTreino(entity.toModel());
      return Right(result);
    } on DataPostFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(DataPostFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> editarTreino(EditarTreinoEntity entity, String id) async {
    try {
      final result = await datasource.editarTreino(entity.toModel(), id);
      return Right(result);
    } on DataPostFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(DataPostFailure());
    }
  }

  @override
  Future<Either<Failure, TreinosEntity>> getTreinoById(String id) async {
    try {
      final result = await datasource.getTreinoById(id);
      return Right(result.toEntity());
    } on DataPostFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(DataPostFailure());
    }
  }
}
