import 'package:bloc/bloc.dart';
import 'package:fominhas/features/treinos/domain/entities/editar_treino_entity.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/state/cubit_state.dart';
import '../../domain/repositories/teinos_repository.dart';

class EditarTreinoCubit extends Cubit<CubitState> {
  final ITreinosRepository repository;

  EditarTreinoCubit(this.repository) : super(CubitState.empty());

  String? descricao;
  String? data;
  List<dynamic> presentes = [];

  onSaveDescricao(String? string) => descricao = string ?? "";
  onSaveData(String? string) => data = string ?? "";
  onSavePresentes(List<dynamic>? lista) => presentes = lista ?? [];

  Future<void> editarTreino(String id) async {
    emit(CubitState.loading());
    final result = await repository.editarTreino(EditarTreinoEntity(descricao!, data!, presentes), id);
    final state = result.fold((error) {
      return CubitState.error(message: (error is DataPostFailure) ? error.message : "Ocorreu um erro");
    }, (entity) {
      return CubitState.success(value: entity);
    });
    emit(state);
  }
}
