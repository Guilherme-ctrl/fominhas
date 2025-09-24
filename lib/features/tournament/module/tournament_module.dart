import 'package:flutter_modular/flutter_modular.dart';
import '../presentation/pages/player_selection_page.dart';
import '../presentation/pages/tournament_page.dart';
import '../presentation/pages/tournaments_management_page.dart';

class TournamentModule extends Module {
  @override
  void routes(r) {
    r.child('/', child: (context) => const PlayerSelectionPage());
    r.child('/tournament', child: (context) => const TournamentPage());
    r.child('/manage', child: (context) => const TournamentsManagementPage());
  }
}
