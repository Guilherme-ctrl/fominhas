import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fominhas/core/errors/failure.dart';
import 'package:fominhas/core/state/cubit_state.dart';
import 'package:fominhas/features/treinos/domain/repositories/teinos_repository.dart';

class TreinoByIdCubit extends Cubit<CubitState> {
  final ITreinosRepository repository;

  TreinoByIdCubit(this.repository) : super(CubitState.empty());

  Future<void> treinoById(String id) async {
    emit(CubitState.loading());
    final result = await repository.getTreinoById(id);
    final state = result.fold((error) {
      return CubitState.error(message: (error is DataPostFailure) ? error.message : "Ocorreu um erro");
    }, (entity) {
      return CubitState.success(value: entity);
    });
    emit(state);
  }
}
