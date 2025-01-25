import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fominhas/core/state/cubit_state.dart';
import 'package:fominhas/features/treinos/domain/entities/adicionar_treinos_entity.dart';
import 'package:fominhas/features/treinos/domain/repositories/teinos_repository.dart';

import '../../../../core/errors/failure.dart';

class AdicionarTreinoCubit extends Cubit<CubitState> {
  final ITreinosRepository repository;

  AdicionarTreinoCubit(this.repository) : super(CubitState.empty());

  String? data;
  String? descricao;

  onSaveData(String? string) => data = string ?? "";
  onSaveDescricao(String? string) => descricao = string ?? "";

  Future<void> adicionarTreino() async {
    emit(CubitState.loading());
    final result = await repository.adicionarTreinos(AdicionarTreinosEntity(data: data!, descricao: descricao!));
    final state = result.fold((error) {
      return CubitState.error(message: (error is DataPostFailure) ? error.message : "Ocorreu um erro");
    }, (entity) {
      return CubitState.success(value: entity);
    });
    emit(state);
  }
}
