import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/state/cubit_state.dart';
import '../../../../core/extensions/cubit_state_extensions.dart';
import '../../../../core/services/logging_service.dart';
import '../../../../core/services/error_handler.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/repositories/login_repository.dart';
import '../../../../core/cubit/user_cubit.dart';

class LoginAppleCubit extends Cubit<CubitState> with CubitLoggingMixin {
  final ILoginRepository _repository;
  final UserCubit _userCubit;

  LoginAppleCubit(this._repository, this._userCubit) : super(CubitState.empty());

  Future<void> signInWithApple() async {
    logOperation('signInWithApple');
    emit(CubitState.loading());
    
    final result = await _repository.signInWithApple();
    final state = result.fold(
      (failure) {
        logError('signInWithApple', failure);
        _logFailure(failure);
        return ErrorHandler.handleFailure(failure, context: 'LoginAppleCubit.signInWithApple');
      },
      (user) {
        _userCubit.setUser(user);
        _logSuccess(user);
        return CubitState.success(value: user);
      },
    );
    
    emit(state);
  }


  void _logSuccess(User user) {
    LoggingService.logStructuredData(
      'login_apple_success',
      {
        'user_id': user.uid,
        'email': user.email ?? 'N/A',
      },
    );
  }

  void _logFailure(Failure failure) {
    LoggingService.logStructuredData(
      'login_apple_failure',
      {
        'failure_type': failure.runtimeType.toString(),
        'message': failure.toString(),
      },
    );
  }
}

// Estados customizados foram removidos em favor do CubitState padrão
// Para acessar dados:
// - Usuário: state.getSuccessValue<User>()
// - Verificar estados: state.isLoading, state.isError, state.isSuccess
// - Obter erro: state.getErrorMessage()
