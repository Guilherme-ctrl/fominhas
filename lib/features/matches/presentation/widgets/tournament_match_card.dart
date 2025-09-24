import 'package:flutter/material.dart';
import '../../../tournament/domain/entities/tournament.dart';

class TournamentMatchCard extends StatelessWidget {
  final Tournament tournament;
  final TournamentMatch match;
  final VoidCallback? onTap;
  final VoidCallback? onManage;

  const TournamentMatchCard({
    super.key,
    required this.tournament,
    required this.match,
    this.onTap,
    this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    final homeTeam = tournament.teams.firstWhere(
      (team) => team.id == match.homeTeamId,
      orElse: () => TournamentTeam(id: '', name: 'Time não encontrado', players: [], reserves: []),
    );
    
    final awayTeam = tournament.teams.firstWhere(
      (team) => team.id == match.awayTeamId,
      orElse: () => TournamentTeam(id: '', name: 'Time não encontrado', players: [], reserves: []),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com torneio e partida
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(match.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tournament.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Partida ${match.matchNumber}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Times e placar
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          homeTeam.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            match.homeScore.toString(),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const Text(
                          'VS',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${match.elapsedMinutes.toString().padLeft(2, '0')}:${match.elapsedSeconds.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(match.status),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          awayTeam.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            match.awayScore.toString(),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Status e botão de ação
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(match.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getStatusColor(match.status).withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _getStatusText(match.status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(match.status),
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  if (match.status != TournamentMatchStatus.finished && onManage != null)
                    ElevatedButton.icon(
                      onPressed: onManage,
                      icon: const Icon(Icons.sports, size: 18),
                      label: const Text('Gerenciar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    )
                  else if (match.status == TournamentMatchStatus.finished)
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 24,
                    ),
                ],
              ),
              
              // Eventos recentes
              if (match.events.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 4),
                Text(
                  'Últimos eventos:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                ...match.events.take(2).map((event) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      Text(
                        '${event.minute}:${event.second.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.sports_soccer, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        event.playerName,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(TournamentMatchStatus status) {
    switch (status) {
      case TournamentMatchStatus.scheduled:
        return Colors.grey;
      case TournamentMatchStatus.inProgress:
        return Colors.green;
      case TournamentMatchStatus.paused:
        return Colors.orange;
      case TournamentMatchStatus.finished:
        return Colors.blue;
    }
  }

  String _getStatusText(TournamentMatchStatus status) {
    switch (status) {
      case TournamentMatchStatus.scheduled:
        return 'Agendada';
      case TournamentMatchStatus.inProgress:
        return 'Em andamento';
      case TournamentMatchStatus.paused:
        return 'Pausada';
      case TournamentMatchStatus.finished:
        return 'Finalizada';
    }
  }
}