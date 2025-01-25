import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fominhas/core/domain/repositories/user/user_repository.dart';
import 'package:fominhas/core/state/cubit_state.dart';

import '../errors/failure.dart';

class UserCubit extends Cubit<CubitState> {
  final IUserRepository repository;

  UserCubit(this.repository) : super(CubitState.empty());

  Future<void> getUser() async {
    emit(CubitState.loading());
    final result = await repository.getGoogleUser();
    final state = result.fold((error) {
      return CubitState.error(message: (error is DataPostFailure) ? error.message : "Ocorreu um erro");
    }, (entity) {
      return CubitState.success(value: entity);
    });
    emit(state);
  }
}
