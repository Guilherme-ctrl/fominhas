import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fominhas/core/domain/entities/jogadores/adicionar_jogadores_entity.dart';
import 'package:fominhas/core/domain/entities/jogadores/jogadores_response_entity.dart';
import 'package:fominhas/core/domain/repositories/jogadores/jogadores_repository.dart';
import 'package:fominhas/core/state/cubit_state.dart';
import '../../../../core/errors/failure.dart';

class EditarJogadorCubit extends Cubit<CubitState> {
  final IJogadoresRepository repository;

  EditarJogadorCubit(this.repository) : super(CubitState.empty());

  String? nome;
  int? numero;
  String? email;
  String? documento;
  JogadoresResponseEntity? dadosOriginais;

  void onSaveDadosOriginais(JogadoresResponseEntity? entity) => dadosOriginais = entity;

  // Função para salvar o nome
  void onSaveNome(String? string) => nome = string ?? "";

  // Função para salvar o número
  void onSaveNumero(String? string) => numero = int.tryParse(string ?? "") ?? 0;

  // Função para salvar o email
  void onSaveEmail(String? string) => email = string ?? "";

  // Função para salvar o documento
  void onSaveDocumento(String? string) => documento = string ?? "";

  Future<void> editarJogador(String jogadorId) async {
    emit(CubitState.loading());
    final result =
        await repository.editarJogador(AdicionarJogadoresEntity(nome: nome!, numero: numero!, email: email!, documento: documento!), jogadorId);
    final state = result.fold((error) {
      return CubitState.error(message: (error is DataPostFailure) ? error.message : "Ocorreu um erro");
    }, (entity) {
      return CubitState.success(value: entity);
    });
    emit(state);
  }
}
