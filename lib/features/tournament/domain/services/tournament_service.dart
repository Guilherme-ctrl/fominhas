import '../../../players/domain/entities/player.dart';
import '../entities/tournament.dart';

class TournamentService {
  /// Algoritmo para dividir jogadores em múltiplos times equilibrados
  /// Considera as posições dos jogadores como sugestão para balanceamento
  static List<TournamentTeam> createBalancedTeams(
    List<Player> selectedPlayers,
    int numberOfTeams,
  ) {
    if (selectedPlayers.length < (numberOfTeams * 4)) {
      throw Exception('Mínimo de ${numberOfTeams * 4} jogadores necessários para criar $numberOfTeams times');
    }

    // Embaralhar jogadores para aleatoriedade
    final shuffledPlayers = List<Player>.from(selectedPlayers);
    shuffledPlayers.shuffle();

    // Separar jogadores por posição (como sugestão)
    final goalkeepers = shuffledPlayers
        .where((p) => p.position == PlayerPosition.goleiro)
        .toList();
    final defenders = shuffledPlayers
        .where((p) => p.position == PlayerPosition.fixo)
        .toList();
    final wings = shuffledPlayers
        .where((p) => p.position == PlayerPosition.ala)
        .toList();
    final pivots = shuffledPlayers
        .where((p) => p.position == PlayerPosition.pivo)
        .toList();

    // Inicializar times vazios
    final teams = <List<Player>>[];
    for (int i = 0; i < numberOfTeams; i++) {
      teams.add(<Player>[]);
    }

    // FASE 1: Distribuir por posição como sugestão (não obrigatório)
    final allPlayersByPosition = [goalkeepers, defenders, wings, pivots];
    final usedPlayers = <Player>{};
    
    for (final positionPlayers in allPlayersByPosition) {
      if (positionPlayers.isNotEmpty) {
        _distributePlayersAsSuggestion(positionPlayers, teams, usedPlayers);
      }
    }

    // FASE 2: Distribuir jogadores restantes garantindo 4 por time
    final remainingPlayers = shuffledPlayers
        .where((p) => !usedPlayers.contains(p))
        .toList();
    
    _distributeRemainingPlayersEqually(remainingPlayers, teams);

    // Criar objetos TournamentTeam
    final tournamentTeams = <TournamentTeam>[];
    final teamColors = ['Azul', 'Vermelho', 'Verde', 'Amarelo', 'Roxo', 'Laranja'];
    final baseId = DateTime.now().millisecondsSinceEpoch;
    
    for (int i = 0; i < teams.length; i++) {
      final teamPlayers = teams[i];
      final starters = teamPlayers.take(4).toList();
      final reserves = teamPlayers.skip(4).toList();
      
      tournamentTeams.add(
        TournamentTeam(
          id: 'team_${i + 1}_$baseId',
          name: 'Time ${teamColors[i % teamColors.length]}',
          players: starters,
          reserves: reserves,
        ),
      );
    }

    return tournamentTeams;
  }

  /// Cria as 4 partidas do torneio com os dois times
  static List<TournamentMatch> createTournamentMatches(
    List<TournamentTeam> teams,
  ) {
    if (teams.length != 2) {
      throw Exception('Exatamente 2 times necessários para criar partidas');
    }

    final matches = <TournamentMatch>[];
    final baseId = DateTime.now().millisecondsSinceEpoch;

    // Criar 4 partidas de 9 minutos cada
    for (int i = 1; i <= 4; i++) {
      matches.add(
        TournamentMatch(
          id: 'match_${i}_$baseId',
          homeTeamId: teams[0].id,
          awayTeamId: teams[1].id,
          matchNumber: i,
          status: TournamentMatchStatus.scheduled,
        ),
      );
    }

    return matches;
  }

  /// Cria partidas round-robin (todos contra todos) para múltiplos times
  /// Garantindo que todos os times joguem o mesmo número de partidas
  static List<TournamentMatch> createRoundRobinMatches(
    List<TournamentTeam> teams,
  ) {
    if (teams.length < 2) {
      throw Exception('Pelo menos 2 times necessários para criar partidas');
    }

    final matches = <TournamentMatch>[];
    final baseId = DateTime.now().millisecondsSinceEpoch;
    int matchCounter = 1;

    // Calcular número de rodadas garantindo pelo menos 4 partidas por time
    // Para n times, cada time joga (n-1) partidas por turno
    // Garantir pelo menos 4 partidas por time
    int matchesPerTeamPerRound = teams.length - 1;
    int minRounds = (4 / matchesPerTeamPerRound).ceil();
    int rounds = minRounds > 2 ? 2 : minRounds.clamp(1, 2);
    
    // Para 2 times: 2 turnos (cada time joga 2 partidas)
    // Para 3 times: 2 turnos (cada time joga 4 partidas) 
    // Para 4+ times: 2 turnos (cada time joga 6+ partidas)
    if (teams.length == 2) {
      rounds = 4; // 4 partidas para ter pelo menos 4 por time
    }
    
    for (int round = 1; round <= rounds; round++) {
      // Criar partidas de todos contra todos para cada turno
      for (int i = 0; i < teams.length; i++) {
        for (int j = i + 1; j < teams.length; j++) {
          // Para 2 times com múltiplas rodadas, alternar mando de campo a cada partida
          final homeTeamIndex = teams.length == 2 
              ? (matchCounter % 2 == 1 ? i : j)
              : (round % 2 == 1 ? i : j);
          final awayTeamIndex = teams.length == 2
              ? (matchCounter % 2 == 1 ? j : i) 
              : (round % 2 == 1 ? j : i);
          
          matches.add(
            TournamentMatch(
              id: 'match_${matchCounter}_$baseId',
              homeTeamId: teams[homeTeamIndex].id,
              awayTeamId: teams[awayTeamIndex].id,
              matchNumber: matchCounter,
              status: TournamentMatchStatus.scheduled,
            ),
          );
          matchCounter++;
        }
      }
    }

    // Note: Match statistics:
    // 2 times: 4 partidas (cada time joga 4 vezes)
    // 3 times: 6 partidas (cada time joga 4 vezes)
    // 4 times: 12 partidas (cada time joga 6 vezes)
    // 5+ times: varia, mas sempre pelo menos 4 partidas por time
    
    return matches;
  }

  /// Atualiza estatísticas do time após uma partida
  static TournamentTeam updateTeamStatsAfterMatch(
    TournamentTeam team,
    int goalsScored,
    int goalsConceded,
  ) {
    final isWin = goalsScored > goalsConceded;
    final isDraw = goalsScored == goalsConceded;
    final isLoss = goalsScored < goalsConceded;

    return team.copyWith(
      points: team.points + (isWin ? 3 : (isDraw ? 1 : 0)),
      goalsScored: team.goalsScored + goalsScored,
      goalsConceded: team.goalsConceded + goalsConceded,
      wins: team.wins + (isWin ? 1 : 0),
      draws: team.draws + (isDraw ? 1 : 0),
      losses: team.losses + (isLoss ? 1 : 0),
    );
  }

  /// Determina o campeão com base nos critérios
  static TournamentTeam? determineChampion(List<TournamentTeam> teams) {
    if (teams.length != 2) return null;

    final team1 = teams[0];
    final team2 = teams[1];

    // Critério 1: Mais pontos
    if (team1.points > team2.points) return team1;
    if (team2.points > team1.points) return team2;

    // Critério 2: Melhor saldo de gols
    if (team1.goalDifference > team2.goalDifference) return team1;
    if (team2.goalDifference > team1.goalDifference) return team2;

    // Critério 3: Mais gols marcados
    if (team1.goalsScored > team2.goalsScored) return team1;
    if (team2.goalsScored > team1.goalsScored) return team2;

    // Em caso de empate total, retorna null (empate)
    return null;
  }

  /// Calcula o tempo total decorrido em segundos
  static int getTotalElapsedTimeInSeconds(int minutes, int seconds) {
    return (minutes * 60) + seconds;
  }

  /// Converte segundos totais para minutos e segundos
  static Map<String, int> convertSecondsToMinutesAndSeconds(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return {
      'minutes': minutes,
      'seconds': seconds,
    };
  }

  /// Verifica se uma partida de 9 minutos terminou
  static bool isMatchTimeFinished(int elapsedMinutes, int elapsedSeconds) {
    const maxMinutes = 9;
    return elapsedMinutes >= maxMinutes;
  }

  /// Formata o tempo da partida para exibição (MM:SS)
  static String formatMatchTime(int minutes, int seconds) {
    final formattedMinutes = minutes.toString().padLeft(2, '0');
    final formattedSeconds = seconds.toString().padLeft(2, '0');
    return '$formattedMinutes:$formattedSeconds';
  }

  /// Cria um evento de gol com opção de assistência
  static TournamentMatchEvent createGoalEvent({
    required String playerId,
    required String playerName,
    required String teamId,
    required int minute,
    required int second,
    String? assistPlayerId,
    String? assistPlayerName,
  }) {
    // Garantir que sempre temos um ID válido
    final finalPlayerId = playerId.isEmpty ? 'player_${DateTime.now().microsecondsSinceEpoch}' : playerId;
    
    return TournamentMatchEvent(
      id: 'event_${DateTime.now().microsecondsSinceEpoch}',
      playerId: finalPlayerId,
      playerName: playerName,
      assistPlayerId: assistPlayerId,
      assistPlayerName: assistPlayerName,
      teamId: teamId,
      minute: minute,
      second: second,
      type: TournamentMatchEventType.goal,
    );
  }

  /// Valida se é possível iniciar um torneio
  static bool canStartTournament(Tournament tournament) {
    return tournament.status == TournamentStatus.setup &&
           tournament.teams.length == 2 &&
           tournament.matches.length == 4 &&
           tournament.teams.every((team) => team.players.isNotEmpty);
  }

  /// Valida se é possível finalizar um torneio
  static bool canFinishTournament(Tournament tournament) {
    return tournament.status == TournamentStatus.inProgress &&
           tournament.matches.every((match) => 
               match.status == TournamentMatchStatus.finished);
  }
  /// Determina o time vencedor do torneio
  static TournamentTeam? determineWinner(List<TournamentTeam> teams) {
    if (teams.isEmpty) return null;
    
    // Ordenar times pelos critérios de classificação
    final sortedTeams = [...teams];
    sortedTeams.sort((a, b) {
      // Critério 1: Mais pontos
      if (a.points != b.points) return b.points.compareTo(a.points);
      
      // Critério 2: Melhor saldo de gols
      if (a.goalDifference != b.goalDifference) {
        return b.goalDifference.compareTo(a.goalDifference);
      }
      
      // Critério 3: Mais gols marcados
      if (a.goalsScored != b.goalsScored) {
        return b.goalsScored.compareTo(a.goalsScored);
      }
      
      // Critério 4: Menos gols sofridos
      if (a.goalsConceded != b.goalsConceded) {
        return a.goalsConceded.compareTo(b.goalsConceded);
      }
      
      // Se ainda empatar, manter ordem original
      return 0;
    });
    
    return sortedTeams.first;
  }
  
  /// Verifica se o torneio tem um vencedor claro (sem empate)
  static bool hasUnambiguousWinner(List<TournamentTeam> teams) {
    if (teams.length < 2) return true;
    
    final sortedTeams = [...teams];
    sortedTeams.sort((a, b) {
      if (a.points != b.points) return b.points.compareTo(a.points);
      if (a.goalDifference != b.goalDifference) return b.goalDifference.compareTo(a.goalDifference);
      return b.goalsScored.compareTo(a.goalsScored);
    });
    
    final first = sortedTeams[0];
    final second = sortedTeams[1];
    
    // Verificar se há empate nos critérios principais
    return first.points != second.points ||
           first.goalDifference != second.goalDifference ||
           first.goalsScored != second.goalsScored;
  }

  /// Obtem estatísticas resumidas do torneio
  static Map<String, dynamic> getTournamentSummary(Tournament tournament) {
    final totalGoals = tournament.teams
        .map((team) => team.goalsScored)
        .fold(0, (a, b) => a + b);
    
    final totalMatches = tournament.matches.length;
    final finishedMatches = tournament.matches
        .where((match) => match.status == TournamentMatchStatus.finished)
        .length;
    
    final winner = determineWinner(tournament.teams);
    
    return {
      'totalGoals': totalGoals,
      'totalMatches': totalMatches,
      'finishedMatches': finishedMatches,
      'isCompleted': tournament.status == TournamentStatus.finished,
      'champion': winner,
      'hasUnambiguousWinner': hasUnambiguousWinner(tournament.teams),
    };
  }
  
  /// Distribui jogadores por posição como sugestão (não obrigatório)
  static void _distributePlayersAsSuggestion(
    List<Player> positionPlayers,
    List<List<Player>> teams,
    Set<Player> usedPlayers,
  ) {
    // Tentar dar um jogador dessa posição para cada time (se possível)
    int teamIndex = 0;
    for (final player in positionPlayers) {
      // Parar se todos os times já estão com 4 jogadores
      if (teams[teamIndex].length < 4) {
        teams[teamIndex].add(player);
        usedPlayers.add(player);
        teamIndex = (teamIndex + 1) % teams.length;
      } else {
        // Procurar próximo time com espaço
        bool added = false;
        for (int i = 0; i < teams.length; i++) {
          if (teams[i].length < 4) {
            teams[i].add(player);
            usedPlayers.add(player);
            added = true;
            break;
          }
        }
        if (!added) break; // Todos os times estão cheios
      }
    }
  }

  /// Distribui jogadores restantes garantindo exatamente 4 por time
  static void _distributeRemainingPlayersEqually(
    List<Player> remainingPlayers,
    List<List<Player>> teams,
  ) {
    // Completar times que têm menos de 4 jogadores
    for (final player in remainingPlayers) {
      // Procurar time com menos jogadores
      int targetTeamIndex = 0;
      for (int i = 1; i < teams.length; i++) {
        if (teams[i].length < teams[targetTeamIndex].length) {
          targetTeamIndex = i;
        }
      }
      
      // Se todos os times têm 4 jogadores, adicionar como reserva
      if (teams[targetTeamIndex].length >= 4) {
        // Encontrar time com menos reservas
        for (int i = 0; i < teams.length; i++) {
          if (teams[i].length < teams[targetTeamIndex].length) {
            targetTeamIndex = i;
          }
        }
      }
      
      teams[targetTeamIndex].add(player);
    }
  }
  
  /// Retorna as cores padrão dos times
  static List<String> getTeamColors() {
    return ['Time Preto', 'Time Branco', 'Time Verde'];
  }
  
  /// Atualiza os nomes dos times para as cores padrão
  static List<TournamentTeam> updateTeamColorsAndNames(List<TournamentTeam> teams) {
    final colors = getTeamColors();
    final updatedTeams = <TournamentTeam>[];
    
    for (int i = 0; i < teams.length && i < colors.length; i++) {
      final team = teams[i];
      updatedTeams.add(team.copyWith(name: colors[i]));
    }
    
    return updatedTeams;
  }
}
