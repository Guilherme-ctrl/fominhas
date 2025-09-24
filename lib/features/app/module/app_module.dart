import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_modular/flutter_modular.dart';

// Core imports
import '../../../core/cubit/user_cubit.dart';

// Login imports
import '../../login/data/datasource/login_datasource.dart';
import '../../login/data/datasource/login_datasource_implementation.dart';
import '../../login/data/repositories/login_repository_implementation.dart';
import '../../login/domain/repositories/login_repository.dart';
import '../../login/module/login_module.dart';
import '../../login/presentation/cubit/login_apple_cubit.dart';
import '../../login/presentation/cubit/login_google_cubit.dart';

// Players imports
import '../../players/data/datasource/players_datasource.dart';
import '../../players/data/datasource/players_datasource_implementation.dart';
import '../../players/data/repositories/players_repository_implementation.dart';
import '../../players/domain/repositories/players_repository.dart';
import '../../players/presentation/cubit/players_cubit.dart';

// Matches imports
import '../../matches/data/datasource/matches_datasource.dart';
import '../../matches/data/datasource/matches_datasource_implementation.dart';
import '../../matches/data/repositories/matches_repository_implementation.dart';
import '../../matches/domain/repositories/matches_repository.dart';
import '../../matches/presentation/cubit/matches_cubit.dart';

// Tournament imports
import '../../tournament/data/datasource/tournament_datasource.dart';
import '../../tournament/data/datasource/tournament_datasource_implementation.dart';
import '../../tournament/data/repositories/tournament_repository_implementation.dart';
import '../../tournament/domain/repositories/tournament_repository.dart';
import '../../tournament/presentation/cubit/tournament_cubit.dart';

// Home imports
import '../../home/module/home_module.dart';
import '../../tournament/module/tournament_module.dart';

class AppModule extends Module {
  @override
  void exportedBinds(Injector i) {}

  @override
  void binds(i) {
    // Firebase instances
    i.addInstance(FirebaseAuth.instance);
    i.addInstance(FirebaseFirestore.instance);


    // Login services
    i.add<ILoginDatasource>(LoginDatasourceImplementation.new);
    i.add<ILoginRepository>(LoginRepositoryImplementation.new);
    
    // Players services
    i.add<IPlayersDatasource>(PlayersDatasourceImplementation.new);
    i.add<IPlayersRepository>(PlayersRepositoryImplementation.new);
    
    // Matches services
    i.add<IMatchesDatasource>(MatchesDatasourceImplementation.new);
    i.add<IMatchesRepository>(MatchesRepositoryImplementation.new);
    
    // Tournament services
    i.add<ITournamentDatasource>(TournamentDatasourceImplementation.new);
    i.add<ITournamentRepository>(TournamentRepositoryImplementation.new);

    // Core cubits
    i.addSingleton(UserCubit.new);

    // Login cubits
    i.addSingleton(LoginAppleCubit.new);
    i.addSingleton(LoginGoogleCubit.new);
    
    // Players cubits
    i.addSingleton(PlayersCubit.new);
    
    // Matches cubits
    i.addSingleton(MatchesCubit.new);
    
    // Tournament cubits
    i.addSingleton(TournamentCubit.new);
  }

  @override
  void routes(r) {
    r.module(Modular.initialRoute, module: LoginModule());
    r.module("${Modular.initialRoute}home/", module: HomeModule());
    r.module("${Modular.initialRoute}tournament/", module: TournamentModule());
  }
}
