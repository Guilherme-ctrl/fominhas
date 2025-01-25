import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:fominhas/core/cubit/get_jogadores_cubit.dart';
import 'package:fominhas/core/cubit/user_cubit.dart';
import 'package:fominhas/core/data/datasource/jogadores/jogadores_datasource.dart';
import 'package:fominhas/core/data/datasource/jogadores/jogadores_datasource_implementation.dart';
import 'package:fominhas/core/data/datasource/user/user_datasource.dart';
import 'package:fominhas/core/data/datasource/user/user_datasource_inplementation.dart';
import 'package:fominhas/core/data/repositories/jogadores/jogadores_repository_implementation.dart';
import 'package:fominhas/core/data/repositories/user/user_repository_implementation.dart';
import 'package:fominhas/core/domain/repositories/jogadores/jogadores_repository.dart';
import 'package:fominhas/core/domain/repositories/user/user_repository.dart';
import 'package:fominhas/core/utils/converters/date_converter.dart';
import 'package:fominhas/core/utils/converters/date_converter_implementation.dart';
import 'package:fominhas/features/home/module/home_module.dart';
import 'package:fominhas/features/login/data/datasource/login_datasource.dart';
import 'package:fominhas/features/login/data/datasource/login_datasource_implementation.dart';
import 'package:fominhas/features/login/data/repositories/login_repository_implementation.dart';
import 'package:fominhas/features/login/domain/repositories/login_repository.dart';
import 'package:fominhas/features/login/module/login_module.dart';
import '../../login/presentation/cubit/login_google_cubit.dart';

class AppModule extends Module {
  @override
  void exportedBinds(Injector i) {
    i.add<ILoginDatasource>(LoginDatasourceImplementation.new);
    i.add<ILoginRepository>(LoginRepositoryImplementation.new);
    i.add<IUserDatasource>(UserDatasourceInplementation.new);
    i.add<IUserRepository>(UserRepositoryImplementation.new);
    i.add<IDateConverter>(DateConverterImplementation.new);
    i.add<IJogadoresDatasource>(JogadoresDatasourceImplementation.new);
    i.add<IJogadoresRepository>(JogadoresRepositoryImplementation.new);
    i.addInstance(FirebaseAuth.instance);
    i.addInstance(FirebaseFirestore.instance);
    i.addSingleton(GetJogadoresCubit.new);

    i.addSingleton(LoginGoogleCubit.new);
    i.addSingleton(UserCubit.new);
  }

  @override
  void binds(i) {}

  @override
  void routes(r) {
    r.module(Modular.initialRoute, module: LoginModule());
    r.module("${Modular.initialRoute}home/", module: HomeModule());
  }
}
