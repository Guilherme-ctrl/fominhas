import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fominhas/core/domain/entities/jogadores/jogadores_response_entity.dart';
import 'package:fominhas/core/domain/repositories/jogadores/jogadores_repository.dart';
import 'package:fominhas/core/errors/failure.dart';
import 'package:fominhas/core/state/cubit_state.dart';

class GetJogadoresCubit extends Cubit<CubitState> {
  final IJogadoresRepository repository;

  GetJogadoresCubit(this.repository) : super(CubitState.empty());

  List<JogadoresResponseEntity> jogadoresList = [];

  Future<void> getJogadores() async {
    emit(CubitState.loading());
    final result = await repository.getJogadores();
    final state = result.fold((error) {
      return CubitState.error(message: (error is DataPostFailure) ? error.message : "Ocorreu um erro");
    }, (entity) {
      jogadoresList = entity;
      return CubitState.success(value: entity);
    });
    emit(state);
  }
}
