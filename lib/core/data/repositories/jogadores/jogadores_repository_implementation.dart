import 'package:dartz/dartz.dart';
import 'package:fominhas/core/data/datasource/jogadores/jogadores_datasource.dart';
import 'package:fominhas/core/domain/entities/jogadores/adicionar_jogadores_entity.dart';
import 'package:fominhas/core/domain/entities/jogadores/jogadores_response_entity.dart';
import 'package:fominhas/core/domain/mappers/jogadores/adicionar_jogadores_mapper.dart';
import 'package:fominhas/core/domain/mappers/jogadores/jogadores_mapper.dart';
import 'package:fominhas/core/domain/repositories/jogadores/jogadores_repository.dart';
import 'package:fominhas/core/errors/failure.dart';

class JogadoresRepositoryImplementation implements IJogadoresRepository {
  final IJogadoresDatasource datasource;

  JogadoresRepositoryImplementation(this.datasource);

  @override
  Future<Either<Failure, bool>> editarPresencas(String jogadorId, String tipo) async {
    try {
      final result = await datasource.editarPresencas(jogadorId, tipo);
      return Right(result);
    } on DataPostFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(DataPostFailure());
    }
  }

  @override
  Future<Either<Failure, List<JogadoresResponseEntity>>> getJogadores() async {
    try {
      final result = await datasource.getJogadores();
      return Right(result.toEntityList());
    } on DataPostFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(DataPostFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> adicionarJogadores(AdicionarJogadoresEntity entity) async {
    try {
      final result = await datasource.adicionarJogadores(entity.toModel());
      return Right(result);
    } on DataPostFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(DataPostFailure());
    }
  }

  @override
  Future<Either<Failure, JogadoresResponseEntity>> getJogadorById(String jogadorId) async {
    try {
      final result = await datasource.getJogadorById(jogadorId);
      return Right(result.toEntity());
    } on DataPostFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(DataPostFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> editarJogador(AdicionarJogadoresEntity entity, String jogadorId) async {
    try {
      final result = await datasource.editarJogador(entity.toModel(), jogadorId);
      return Right(result);
    } on DataPostFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(DataPostFailure());
    }
  }
}
