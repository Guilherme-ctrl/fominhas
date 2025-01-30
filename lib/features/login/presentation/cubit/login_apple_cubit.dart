import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fominhas/core/state/cubit_state.dart';
import 'package:fominhas/features/login/domain/repositories/login_repository.dart';

import '../../../../core/errors/failure.dart';

class LoginAppleCubit extends Cubit<CubitState> {
  final ILoginRepository repository;

  LoginAppleCubit(this.repository) : super(CubitState.empty());

  Future<void> loginApple() async {
    emit(CubitState.loading());
    final result = await repository.loginApple();
    final state = result.fold((error) {
      return CubitState.error(message: (error is DataPostFailure) ? error.message : "Ocorreu um erro");
    }, (entity) {
      return CubitState.success(value: entity);
    });
    emit(state);
  }
}
