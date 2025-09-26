import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../players/domain/entities/player.dart';
import '../../domain/entities/tournament.dart';
import '../../domain/services/tournament_service.dart';

class MatchEvents extends StatefulWidget {
  final TournamentMatch match;
  final TournamentTeam homeTeam;
  final TournamentTeam awayTeam;
  final Function(TournamentMatch, List<TournamentMatchEvent>) onEventAdded;
  final int currentMinute;
  final int currentSecond;

  const MatchEvents({
    super.key,
    required this.match,
    required this.homeTeam,
    required this.awayTeam,
    required this.onEventAdded,
    this.currentMinute = 0,
    this.currentSecond = 0,
  });

  @override
  State<MatchEvents> createState() => _MatchEventsState();
}

class _MatchEventsState extends State<MatchEvents> {
  void _showGoalDialog(TournamentTeam team) {
    showDialog(
      context: context,
      builder: (context) => _GoalDialog(
        team: team,
        currentMinute: widget.currentMinute,
        currentSecond: widget.currentSecond,
        onGoalScored: (events) {
          widget.onEventAdded(widget.match, events);
        },
      ),
    );
  }

  Widget _buildTeamGoalButton(TournamentTeam team, bool isHome) {
    final score = isHome ? widget.match.homeScore : widget.match.awayScore;
    // Usar cor neutra para ambos os times
    final color = AppTheme.neutralTeamColor;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: widget.match.status != TournamentMatchStatus.finished ? () => _showGoalDialog(team) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmallButton = constraints.maxWidth < 120;
              final teamNameFontSize = isSmallButton ? 12.0 : 16.0;
              final scoreFontSize = isSmallButton ? 18.0 : 24.0;
              final goalTextFontSize = isSmallButton ? 10.0 : 12.0;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      team.name,
                      style: TextStyle(
                        fontSize: teamNameFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  SizedBox(height: isSmallButton ? 4 : 8),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallButton ? 8 : 12,
                      vertical: isSmallButton ? 2 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      score.toString(),
                      style: TextStyle(
                        fontSize: scoreFontSize,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallButton ? 2 : 4),
                  Text(
                    'GOAL!',
                    style: TextStyle(fontSize: goalTextFontSize),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    if (widget.match.events.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Nenhum evento registrado ainda', style: TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
      );
    }

    return Column(
      children: widget.match.events.map((event) {
        // Usar cor neutra para todos os eventos
        final teamColor = AppTheme.neutralTeamColor;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: teamColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: teamColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: teamColor, borderRadius: BorderRadius.circular(4)),
                child: Text(
                  '${event.minute}:${event.second.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                event.type == TournamentMatchEventType.goal ? Icons.sports_soccer : Icons.handshake,
                size: 20,
                color: event.type == TournamentMatchEventType.goal ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (event.type == TournamentMatchEventType.goal)
                      Text('⚽ Gol de ${event.playerName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))
                    else if (event.type == TournamentMatchEventType.assist)
                      Text('🤝 Assistência de ${event.playerName}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.orange)),
                    if (event.type == TournamentMatchEventType.goal && event.assistPlayerName != null)
                      Text('👥 Assistência: ${event.assistPlayerName}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final cardMargin = isSmallScreen ? 8.0 : 16.0;
    final headerPadding = isSmallScreen ? 12.0 : 16.0;
    final contentPadding = isSmallScreen ? 12.0 : 16.0;
    final headerFontSize = isSmallScreen ? 16.0 : 18.0;
    final vsPadding = isSmallScreen ? 8.0 : 12.0;
    final vsSpacing = isSmallScreen ? 8.0 : 16.0;
    final vsFontSize = isSmallScreen ? 14.0 : 18.0;

    return Container(
      margin: EdgeInsets.all(cardMargin),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(headerPadding),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Text(
              'Marcar Gol',
              style: TextStyle(
                fontSize: headerFontSize,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(contentPadding),
            child: Row(
              children: [
                _buildTeamGoalButton(widget.homeTeam, true),
                SizedBox(width: vsSpacing),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: vsPadding,
                    vertical: isSmallScreen ? 6.0 : 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'VS',
                    style: TextStyle(
                      fontSize: vsFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: vsSpacing),
                _buildTeamGoalButton(widget.awayTeam, false),
              ],
            ),
          ),
          if (widget.match.events.isNotEmpty) ...[
            const Divider(),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: contentPadding,
                vertical: isSmallScreen ? 6.0 : 8.0,
              ),
              child: Text(
                'Eventos da Partida',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14.0 : 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildEventsList(),
            SizedBox(height: contentPadding),
          ],
        ],
      ),
    );
  }
}

class _GoalDialog extends StatefulWidget {
  final TournamentTeam team;
  final int currentMinute;
  final int currentSecond;
  final Function(List<TournamentMatchEvent>) onGoalScored;

  const _GoalDialog({required this.team, required this.currentMinute, required this.currentSecond, required this.onGoalScored});

  @override
  State<_GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<_GoalDialog> {
  Player? selectedScorer;
  Player? selectedAssist;

  void _confirmGoal() {
    if (selectedScorer == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione quem fez o gol'), backgroundColor: Colors.red));
      return;
    }

    // Debug: mostrar informações do jogador selecionado

    // Garantir que temos um ID válido para o jogador que marcou o gol
    final playerId = selectedScorer!.id ?? selectedScorer!.name.replaceAll(' ', '_').toLowerCase();

    // Assist player validation handled below when creating events

    // Criar evento de gol
    final goalEvent = TournamentService.createGoalEvent(
      playerId: playerId,
      playerName: selectedScorer!.name,
      teamId: widget.team.id,
      minute: widget.currentMinute,
      second: widget.currentSecond,
      assistPlayerId: selectedAssist?.id ?? selectedAssist?.name.replaceAll(' ', '_').toLowerCase(),
      assistPlayerName: selectedAssist?.name,
    );

    // Criar lista de eventos para adicionar
    final eventsToAdd = <TournamentMatchEvent>[goalEvent];

    // Criar evento de assistência separado se houver
    if (selectedAssist != null) {
      final assistPlayerId = selectedAssist!.id ?? selectedAssist!.name.replaceAll(' ', '_').toLowerCase();

      final assistEvent = TournamentMatchEvent(
        id: 'event_assist_${DateTime.now().microsecondsSinceEpoch}',
        playerId: assistPlayerId,
        playerName: selectedAssist!.name,
        teamId: widget.team.id,
        minute: widget.currentMinute,
        second: widget.currentSecond,
        type: TournamentMatchEventType.assist,
      );

      eventsToAdd.add(assistEvent);
    }

    widget.onGoalScored(eventsToAdd);

    Navigator.of(context).pop();

    // Mostrar confirmação
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚽ Gol registrado para ${selectedScorer!.name}!', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildPlayerSelector({
    required String title,
    required Player? selectedPlayer,
    required Function(Player?) onPlayerSelected,
    bool allowNone = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
          child: DropdownButton<Player?>(
            value: selectedPlayer,
            isExpanded: true,
            underline: const SizedBox(),
            hint: Text('Selecione o ${title.toLowerCase()}'),
            items: [
              if (allowNone) const DropdownMenuItem<Player?>(value: null, child: Text('Nenhum')),
              ...widget.team.players.map((player) => DropdownMenuItem<Player?>(value: player, child: Text(player.name))),
              ...widget.team.reserves.map((player) => DropdownMenuItem<Player?>(value: player, child: Text('${player.name} (Reserva)'))),
            ],
            onChanged: onPlayerSelected,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Gol do ${widget.team.name}'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.neutralTeamColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.access_time, color: AppTheme.neutralTeamColor),
                  const SizedBox(width: 8),
                  Text(
                    'Tempo: ${TournamentService.formatMatchTime(widget.currentMinute, widget.currentSecond)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.neutralTeamColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildPlayerSelector(
              title: 'Quem fez o gol?',
              selectedPlayer: selectedScorer,
              onPlayerSelected: (player) {
                setState(() {
                  selectedScorer = player;
                  // Se selecionou o mesmo jogador para assistência, limpa a assistência
                  if (selectedAssist == player) {
                    selectedAssist = null;
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            _buildPlayerSelector(
              title: 'Quem deu assistência?',
              selectedPlayer: selectedAssist,
              onPlayerSelected: (player) {
                setState(() {
                  // Não pode ser o mesmo jogador que marcou
                  if (player != selectedScorer) {
                    selectedAssist = player;
                  }
                });
              },
              allowNone: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: _confirmGoal,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
          child: const Text('Confirmar Gol'),
        ),
      ],
    );
  }
}
