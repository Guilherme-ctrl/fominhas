import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../../domain/services/tournament_service.dart';
import '../../domain/entities/tournament.dart';
import '../../../players/domain/entities/player.dart';
import '../../../tournament/presentation/cubit/tournament_cubit.dart';

class TeamReviewPage extends StatefulWidget {
  final String tournamentName;
  final List<TournamentTeam> teams;

  const TeamReviewPage({
    super.key,
    required this.tournamentName,
    required this.teams,
  });

  @override
  State<TeamReviewPage> createState() => _TeamReviewPageState();
}

class _TeamReviewPageState extends State<TeamReviewPage> {
  late List<TournamentTeam> editableTeams;
  Player? selectedPlayer;
  int? selectedFromTeam;

  @override
  void initState() {
    super.initState();
    editableTeams = widget.teams.map((team) => team.copyWith()).toList();
  }

  void _movePlayer(Player player, int fromTeamIndex, int toTeamIndex) {
    if (fromTeamIndex == toTeamIndex) return;

    setState(() {
      // Remover jogador do time original
      final fromTeam = editableTeams[fromTeamIndex];
      final updatedFromPlayers = fromTeam.players.where((p) => p.id != player.id).toList();
      final updatedFromReserves = fromTeam.reserves.where((p) => p.id != player.id).toList();
      
      editableTeams[fromTeamIndex] = fromTeam.copyWith(
        players: updatedFromPlayers,
        reserves: updatedFromReserves,
      );

      // Adicionar jogador ao time destino
      final toTeam = editableTeams[toTeamIndex];
      if (toTeam.players.length < 4) {
        // Adicionar como titular
        editableTeams[toTeamIndex] = toTeam.copyWith(
          players: [...toTeam.players, player],
        );
      } else {
        // Adicionar como reserva
        editableTeams[toTeamIndex] = toTeam.copyWith(
          reserves: [...toTeam.reserves, player],
        );
      }
    });
  }

  void _movePlayerToReserves(Player player, int teamIndex) {
    setState(() {
      final team = editableTeams[teamIndex];
      if (team.players.contains(player)) {
        final updatedPlayers = team.players.where((p) => p.id != player.id).toList();
        final updatedReserves = [...team.reserves, player];
        
        editableTeams[teamIndex] = team.copyWith(
          players: updatedPlayers,
          reserves: updatedReserves,
        );
      }
    });
  }

  void _movePlayerToStarters(Player player, int teamIndex) {
    setState(() {
      final team = editableTeams[teamIndex];
      if (team.reserves.contains(player) && team.players.length < 4) {
        final updatedReserves = team.reserves.where((p) => p.id != player.id).toList();
        final updatedPlayers = [...team.players, player];
        
        editableTeams[teamIndex] = team.copyWith(
          players: updatedPlayers,
          reserves: updatedReserves,
        );
      }
    });
  }

  void _regenerateTeams() {
    // Coletar todos os jogadores
    final allPlayers = <Player>[];
    for (final team in editableTeams) {
      allPlayers.addAll(team.players);
      allPlayers.addAll(team.reserves);
    }

    // Regenerar times
    final newTeams = TournamentService.createBalancedTeams(allPlayers, editableTeams.length);
    
    setState(() {
      editableTeams = newTeams;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Times reorganizados automaticamente!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _confirmTeams() {
    
    // Validar se todos os times têm pelo menos 4 jogadores
    for (int i = 0; i < editableTeams.length; i++) {
      final team = editableTeams[i];
      
      if (team.players.length < 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${team.name} precisa ter pelo menos 4 jogadores titulares!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }


    // Criar partidas para o torneio
    List<TournamentMatch> matches = [];
    
    try {
      if (editableTeams.length == 2) {
        // Para 2 times: 4 partidas de 9 minutos
        matches = TournamentService.createTournamentMatches(editableTeams);
      } else {
        // Para 3+ times: partidas round-robin (todos contra todos)
        matches = TournamentService.createRoundRobinMatches(editableTeams);
      }
    } catch (e) {
      // Log erro na criação de partidas para monitoramento
      FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.current,
        fatal: false,
        information: [
          'Erro ao criar partidas do torneio',
          'Nome do torneio: ${widget.tournamentName}',
          'Número de times: ${editableTeams.length}',
          'Tipo de torneio: ${editableTeams.length == 2 ? "2 times" : "round-robin"}',
        ],
      );
      
      // Exibir erro para o usuário
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao configurar partidas: $e'),
          backgroundColor: Colors.orange,
        ),
      );
      
      // Continuar com lista vazia de partidas como fallback
      matches = [];
    }

    
    try {
      // Criar torneio
      Modular.get<TournamentCubit>().createTournament(
        name: widget.tournamentName,
        date: DateTime.now(),
        teams: editableTeams,
        matches: matches,
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar torneio: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    
    // Mostrar mensagem de sucesso
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Torneio "${widget.tournamentName}" criado com sucesso!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
    
    // Navegar de volta ao menu principal (aba de torneios)
    try {
      // Navegar para Home sem empilhar novas telas
      Modular.to.navigate('/home/');
    } catch (e) {
      // Log erro de navegação para monitoramento
      FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.current,
        fatal: false,
        information: [
          'Erro na navegação após criação do torneio',
          'Torneio criado: ${widget.tournamentName}',
          'Rota de destino: /home/',
        ],
      );
      
      // Fallback: tentar navegar usando Navigator padrão
      try {
        Navigator.of(context).popUntil((route) => route.isFirst);
      } catch (fallbackError) {
        // Log fallback error
        FirebaseCrashlytics.instance.recordError(
          fallbackError,
          StackTrace.current,
          fatal: false,
          information: [
            'Erro no fallback de navegação',
            'Torneio: ${widget.tournamentName}',
          ],
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revisar Times'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _regenerateTeams,
            icon: const Icon(Icons.shuffle),
            tooltip: 'Reorganizar Times',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header com informações
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.blue.shade200),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.tournamentName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${editableTeams.length} times • Toque e segure um jogador para mover entre times',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Lista de times
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: editableTeams.length,
              itemBuilder: (context, index) {
                return _buildTeamCard(editableTeams[index], index);
              },
            ),
          ),

          // Botão confirmar
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _confirmTeams();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Confirmar Times e Iniciar Torneio',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard(TournamentTeam team, int teamIndex) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: _getTeamColor(teamIndex),
              child: Text(
                '${teamIndex + 1}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    team.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Titulares: ${team.players.length}/4 • Reservas: ${team.reserves.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: team.players.length < 4 ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        children: [
          // Titulares
          if (team.players.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Titulares',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...team.players.map((player) => 
                    _buildPlayerTile(player, teamIndex, isStarter: true)
                  ),
                ],
              ),
            ),
          ],

          // Reservas
          if (team.reserves.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reservas',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...team.reserves.map((player) => 
                    _buildPlayerTile(player, teamIndex, isStarter: false)
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayerTile(Player player, int teamIndex, {required bool isStarter}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          backgroundColor: _getPositionColor(player.position),
          radius: 16,
          child: Text(
            _getPositionAbbreviation(player.position),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          player.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(_getPositionName(player.position)),
        trailing: PopupMenuButton<String>(
          onSelected: (action) {
            switch (action) {
              case 'move_team':
                _showMoveTeamDialog(player, teamIndex);
                break;
              case 'move_starters':
                if (!isStarter) _movePlayerToStarters(player, teamIndex);
                break;
              case 'move_reserves':
                if (isStarter) _movePlayerToReserves(player, teamIndex);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'move_team',
              child: Row(
                children: [
                  Icon(Icons.swap_horiz),
                  SizedBox(width: 8),
                  Text('Mover para outro time'),
                ],
              ),
            ),
            if (!isStarter)
              const PopupMenuItem(
                value: 'move_starters',
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Promover a titular'),
                  ],
                ),
              ),
            if (isStarter)
              const PopupMenuItem(
                value: 'move_reserves',
                child: Row(
                  children: [
                    Icon(Icons.star_border, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Mover para reserva'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showMoveTeamDialog(Player player, int fromTeamIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mover ${player.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Para qual time deseja mover este jogador?'),
            const SizedBox(height: 16),
            ...editableTeams.asMap().entries.map((entry) {
              final index = entry.key;
              final team = entry.value;
              
              if (index == fromTeamIndex) return const SizedBox();
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getTeamColor(index),
                  child: Text('${index + 1}'),
                ),
                title: Text(team.name),
                subtitle: Text('${team.players.length + team.reserves.length} jogadores'),
                onTap: () {
                  Navigator.of(context).pop();
                  _movePlayer(player, fromTeamIndex, index);
                },
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Color _getTeamColor(int index) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }

  Color _getPositionColor(PlayerPosition position) {
    switch (position) {
      case PlayerPosition.goleiro:
        return Colors.green;
      case PlayerPosition.fixo:
        return Colors.red;
      case PlayerPosition.ala:
        return Colors.blue;
      case PlayerPosition.pivo:
        return Colors.orange;
    }
  }

  String _getPositionAbbreviation(PlayerPosition position) {
    switch (position) {
      case PlayerPosition.goleiro:
        return 'G';
      case PlayerPosition.fixo:
        return 'F';
      case PlayerPosition.ala:
        return 'A';
      case PlayerPosition.pivo:
        return 'P';
    }
  }

  String _getPositionName(PlayerPosition position) {
    switch (position) {
      case PlayerPosition.goleiro:
        return 'Goleiro';
      case PlayerPosition.fixo:
        return 'Fixo';
      case PlayerPosition.ala:
        return 'Ala';
      case PlayerPosition.pivo:
        return 'Pivô';
    }
  }
}