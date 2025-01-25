import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fominhas/core/domain/repositories/jogadores/jogadores_repository.dart';
import 'package:fominhas/core/state/cubit_state.dart';
import '../../../../core/errors/failure.dart';

class JogadorByIdCubit extends Cubit<CubitState> {
  final IJogadoresRepository repository;

  JogadorByIdCubit(this.repository) : super(CubitState.empty());

  Future<void> jogadorById(String jogadorId) async {
    emit(CubitState.loading());
    final result = await repository.getJogadorById(jogadorId);
    final state = result.fold((error) {
      return CubitState.error(message: (error is DataPostFailure) ? error.message : "Ocorreu um erro");
    }, (entity) {
      return CubitState.success(value: entity);
    });
    emit(state);
  }
}
