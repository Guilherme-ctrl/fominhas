import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../state/cubit_state.dart';
import '../extensions/cubit_state_extensions.dart';
import '../services/logging_service.dart';

class UserCubit extends Cubit<CubitState> with CubitLoggingMixin {
  UserCubit() : super(CubitState.empty());

  void setUser(User? user) {
    logOperation('setUser', data: {'userId': user?.uid, 'hasUser': user != null});
    
    if (user != null) {
      emit(CubitState.success(value: user));
      
      LoggingService.logStructuredData(
        'user_set',
        {
          'user_id': user.uid,
          'email': user.email ?? 'N/A',
          'display_name': user.displayName ?? 'N/A',
        },
      );
    } else {
      emit(CubitState.empty());
      LoggingService.info('Usuário removido do estado');
    }
  }

  void clearUser() {
    logOperation('clearUser');
    emit(CubitState.empty());
    
    LoggingService.logStructuredData(
      'user_cleared',
      {},
    );
  }
  
  /// Obtém o usuário atual de forma segura
  User? get currentUser {
    return state.getSuccessValue<User>();
  }
  
  /// Verifica se há um usuário logado
  bool get hasUser {
    return state.isSuccess && currentUser != null;
  }
}