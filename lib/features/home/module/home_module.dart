import 'package:flutter_modular/flutter_modular.dart';
import 'package:fominhas/features/jogadores/presentation/adicionar_jogadores_page.dart';
import 'package:fominhas/features/jogadores/presentation/cubit/adicionar_jogadores_cubit.dart';
import 'package:fominhas/features/home/presentation/navegation_controller.dart';
import 'package:fominhas/features/jogadores/presentation/cubit/editar_jogador_cubit.dart';
import 'package:fominhas/features/jogadores/presentation/cubit/jogador_by_id_cubit.dart';
import 'package:fominhas/features/jogadores/presentation/editar_jogador_page.dart';
import 'package:fominhas/features/treinos/presentation/adicionar_treino_page.dart';
import 'package:fominhas/features/treinos/presentation/cubit/adicionar_treino_cubit.dart';
import 'package:fominhas/features/treinos/presentation/cubit/editar_presenca_cubit.dart';
import 'package:fominhas/features/treinos/presentation/cubit/editar_treino_cubit.dart';
import 'package:fominhas/features/treinos/presentation/cubit/treino_by_id_cubit.dart';
import 'package:fominhas/features/treinos/presentation/editar_treino_page.dart';

import '../../app/module/app_module.dart';
import '../../treinos/data/datasource/treinos_datasource.dart';
import '../../treinos/data/datasource/treinos_datasource_implementation.dart';
import '../../treinos/data/repositories/treinos_repository_implementation.dart';
import '../../treinos/domain/repositories/teinos_repository.dart';
import '../../treinos/presentation/cubit/treinos_cubit.dart';

class HomeModule extends Module {
  @override
  List<Module> get imports => [AppModule()];

  @override
  void binds(i) {
    i.add<ITreinosDatasource>(TreinosDatasourceImplementation.new);
    i.add<ITreinosRepository>(TreinosRepositoryImplementation.new);
    i.addSingleton(TreinosCubit.new);
    i.addSingleton(AdicionarTreinoCubit.new);
    i.addSingleton(EditarPresencaCubit.new);
    i.addSingleton(EditarTreinoCubit.new);
    i.addSingleton(TreinoByIdCubit.new);
    i.addSingleton(AdicionarJogadoresCubit.new);
    i.addSingleton(JogadorByIdCubit.new);
    i.addSingleton(EditarJogadorCubit.new);
  }

  @override
  void routes(r) {
    r.child(Modular.initialRoute, child: (context) => NavegationController());
    r.child("${Modular.initialRoute}adicionar_treinos/", child: (context) => AdicionarTreinoPage());
    r.child("${Modular.initialRoute}editar_treinos/", child: (context) => EditarTreinoPage(treinoId: r.args.data));
    r.child("${Modular.initialRoute}adicionar_jogador/", child: (context) => AdicionarJogadorPage());
    r.child("${Modular.initialRoute}editar_jogador/", child: (context) => EditarJogadorPage(jogadorId: r.args.data));
  }
}
