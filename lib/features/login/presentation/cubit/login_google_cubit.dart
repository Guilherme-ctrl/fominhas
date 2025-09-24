import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/state/cubit_state.dart';
import '../../../../core/extensions/cubit_state_extensions.dart';
import '../../../../core/services/error_handler.dart';
import '../../domain/repositories/login_repository.dart';
import '../../../../core/cubit/user_cubit.dart';

class LoginGoogleCubit extends Cubit<CubitState> with CubitLoggingMixin {
  final ILoginRepository _repository;
  final UserCubit _userCubit;

  LoginGoogleCubit(this._repository, this._userCubit) : super(CubitState.empty());

  Future<void> signInWithGoogle() async {
    logOperation('signInWithGoogle');
    emit(CubitState.loading());

    final result = await _repository.signInWithGoogle();
    final state = result.fold(
      (failure) {
        logError('signInWithGoogle', failure);
        return ErrorHandler.handleFailure(failure, context: 'LoginGoogleCubit.signInWithGoogle');
      },
      (user) {
        _userCubit.setUser(user);
        return CubitState.success(value: user);
      },
    );
    
    emit(state);
  }

}
