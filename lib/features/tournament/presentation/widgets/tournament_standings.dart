import 'package:flutter/material.dart';
import '../../domain/entities/tournament.dart';
import '../../domain/services/tournament_service.dart';

class TournamentStandings extends StatelessWidget {
  final Tournament tournament;

  const TournamentStandings({
    super.key,
    required this.tournament,
  });

  List<TournamentTeam> get _sortedTeams {
    final teams = List<TournamentTeam>.from(tournament.teams);
    
    // Ordenar por critérios: 1) Pontos, 2) Saldo de gols, 3) Gols marcados
    teams.sort((a, b) {
      // Critério 1: Pontos (descendente)
      if (a.points != b.points) {
        return b.points.compareTo(a.points);
      }
      
      // Critério 2: Saldo de gols (descendente)
      if (a.goalDifference != b.goalDifference) {
        return b.goalDifference.compareTo(a.goalDifference);
      }
      
      // Critério 3: Gols marcados (descendente)
      return b.goalsScored.compareTo(a.goalsScored);
    });
    
    return teams;
  }

  Widget _buildStandingsHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Classificação do Torneio',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
          if (tournament.status == TournamentStatus.finished && tournament.championTeamId != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.yellow.shade600,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'CAMPEÃO: ${_getTeamById(tournament.championTeamId!)?.name ?? 'N/A'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStandingsTable() {
    return Column(
      children: [
        // Cabeçalho da tabela
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
          ),
          child: Row(
            children: [
              const SizedBox(width: 30), // Posição
              const Expanded(flex: 3, child: Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
              const Expanded(flex: 1, child: Text('J', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              const Expanded(flex: 1, child: Text('V', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              const Expanded(flex: 1, child: Text('E', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              const Expanded(flex: 1, child: Text('D', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              const Expanded(flex: 1, child: Text('GP', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              const Expanded(flex: 1, child: Text('GC', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              const Expanded(flex: 1, child: Text('SG', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              const Expanded(flex: 1, child: Text('Pts', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
            ],
          ),
        ),
        // Linhas da tabela
        ..._sortedTeams.asMap().entries.map((entry) {
          final index = entry.key;
          final team = entry.value;
          final position = index + 1;
          
          return _buildTeamRow(team, position);
        }),
      ],
    );
  }

  Widget _buildTeamRow(TournamentTeam team, int position) {
    final isChampion = tournament.championTeamId == team.id;
    final rowColor = position == 1 ? Colors.yellow.shade50 : 
                    position == 2 ? Colors.grey.shade50 : 
                    Colors.white;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: rowColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Posição
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: position == 1 ? Colors.yellow.shade600 : 
                     position == 2 ? Colors.grey.shade400 : 
                     Colors.blue.shade400,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                position.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          
          // Nome do time
          Expanded(
            flex: 3,
            child: Row(
              children: [
                if (isChampion) ...[
                  Icon(Icons.star, color: Colors.yellow.shade600, size: 16),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    team.name,
                    style: TextStyle(
                      fontWeight: isChampion ? FontWeight.bold : FontWeight.w500,
                      color: isChampion ? Colors.yellow.shade700 : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Estatísticas
          Expanded(flex: 1, child: Text('${team.matchesPlayed}', textAlign: TextAlign.center)),
          Expanded(flex: 1, child: Text('${team.wins}', textAlign: TextAlign.center)),
          Expanded(flex: 1, child: Text('${team.draws}', textAlign: TextAlign.center)),
          Expanded(flex: 1, child: Text('${team.losses}', textAlign: TextAlign.center)),
          Expanded(flex: 1, child: Text('${team.goalsScored}', textAlign: TextAlign.center)),
          Expanded(flex: 1, child: Text('${team.goalsConceded}', textAlign: TextAlign.center)),
          Expanded(
            flex: 1, 
            child: Text(
              '${team.goalDifference > 0 ? '+' : ''}${team.goalDifference}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: team.goalDifference > 0 ? Colors.green : 
                       team.goalDifference < 0 ? Colors.red : null,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 1, 
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${team.points}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Legenda:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              _buildLegendItem('J', 'Jogos'),
              _buildLegendItem('V', 'Vitórias'),
              _buildLegendItem('E', 'Empates'),
              _buildLegendItem('D', 'Derrotas'),
              _buildLegendItem('GP', 'Gols Pró'),
              _buildLegendItem('GC', 'Gols Contra'),
              _buildLegendItem('SG', 'Saldo de Gols'),
              _buildLegendItem('Pts', 'Pontos'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Sistema de pontuação: Vitória = 3pts • Empate = 1pt • Derrota = 0pts',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String abbreviation, String full) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$abbreviation:',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          full,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildTournamentSummary() {
    final summary = TournamentService.getTournamentSummary(tournament);
    
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade100, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'Resumo do Torneio',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Partidas',
                  '${summary['finishedMatches']}/${summary['totalMatches']}',
                  Icons.sports_soccer,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Gols',
                  '${summary['totalGoals']}',
                  Icons.sports,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Status',
                  summary['isCompleted'] ? 'Finalizado' : 'Em andamento',
                  summary['isCompleted'] ? Icons.check_circle : Icons.access_time,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.blue.shade600),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  TournamentTeam? _getTeamById(String teamId) {
    try {
      return tournament.teams.firstWhere((team) => team.id == teamId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Column(
        children: [
          _buildStandingsHeader(),
          _buildStandingsTable(),
          _buildLegend(),
          _buildTournamentSummary(),
        ],
      ),
    );
  }
}