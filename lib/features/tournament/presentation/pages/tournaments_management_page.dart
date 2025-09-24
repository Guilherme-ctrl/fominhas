import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../../core/state/cubit_state.dart';
import '../../../../core/extensions/cubit_state_extensions.dart';
import '../../domain/entities/tournament.dart';
import '../../domain/services/tournament_service.dart';
import '../../domain/services/photo_service.dart';
import '../../domain/services/share_service.dart';
import '../../domain/services/instagram_service.dart';
import '../../../players/domain/entities/player.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/sport_widgets.dart';
import '../cubit/tournament_cubit.dart';
import '../widgets/match_timer.dart';
import '../widgets/match_events.dart';

class TournamentsManagementPage extends StatefulWidget {
  const TournamentsManagementPage({super.key});

  @override
  State<TournamentsManagementPage> createState() => _TournamentsManagementPageState();
}

class _TournamentsManagementPageState extends State<TournamentsManagementPage> {
  Map<String, bool> expandedTournaments = {};
  Map<String, int> selectedMatches = {}; // tournamentId -> matchIndex
  List<Tournament> _localTournaments = []; // Cache local dos torneios
  DateTime? _lastUpdateTime;
  Timer? _updateTimer;
  static const Duration _updateThrottle = Duration(seconds: 30); // Throttle Firebase updates

  @override
  void initState() {
    super.initState();
    _loadTournaments();
  }
  
  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _loadTournaments() {
    Modular.get<TournamentCubit>().loadTournaments();
  }

  Tournament _updateTeamStatsAfterMatch(Tournament tournament, TournamentMatch match) {
    final homeTeam = tournament.teams.firstWhere((team) => team.id == match.homeTeamId);
    final awayTeam = tournament.teams.firstWhere((team) => team.id == match.awayTeamId);
    
    
    // Atualizar estatísticas dos times
    final updatedHomeTeam = TournamentService.updateTeamStatsAfterMatch(
      homeTeam, 
      match.homeScore, 
      match.awayScore
    );
    
    final updatedAwayTeam = TournamentService.updateTeamStatsAfterMatch(
      awayTeam, 
      match.awayScore, 
      match.homeScore
    );
    
    // Atualizar lista de times
    final updatedTeams = tournament.teams.map((team) {
      if (team.id == homeTeam.id) return updatedHomeTeam;
      if (team.id == awayTeam.id) return updatedAwayTeam;
      return team;
    }).toList();
    
    
    return tournament.copyWith(teams: updatedTeams);
  }
  
  Tournament _checkAndFinishTournamentIfComplete(Tournament tournament) {
    // Verificar se todas as partidas foram finalizadas
    final allMatchesFinished = tournament.matches.isNotEmpty &&
        tournament.matches.every((match) => match.status == TournamentMatchStatus.finished);
    
    if (allMatchesFinished && tournament.status != TournamentStatus.finished) {
      
      // Determinar o campeão
      final winner = TournamentService.determineWinner(tournament.teams);
      
      // Finalizar torneio
      final finishedTournament = tournament.copyWith(
        status: TournamentStatus.finished,
        championTeamId: winner?.id,
        updatedAt: DateTime.now(),
      );
      
      // Mostrar notificação
      if (mounted) {
        final winnerName = winner?.name ?? 'Time não identificado';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🏆 Torneio "${tournament.name}" finalizado! Campeão: $winnerName'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: '📷 Foto do Campeão',
              textColor: Colors.white,
              onPressed: () => _showWinnerPhotoDialog(finishedTournament),
            ),
          ),
        );
      }
      
      return finishedTournament;
    }
    
    return tournament;
  }
  
  void _showAddMatchDialog(Tournament tournament) {
    String? selectedHomeTeamId;
    String? selectedAwayTeamId;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Adicionar Nova Partida'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Selecione os times para a nova partida:',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 16),
              
              // Time da casa
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Time da Casa',
                  border: OutlineInputBorder(),
                ),
                initialValue: selectedHomeTeamId,
                items: tournament.teams.map((team) {
                  return DropdownMenuItem(
                    value: team.id,
                    child: Text(team.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    selectedHomeTeamId = value;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Time visitante
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Time Visitante',
                  border: OutlineInputBorder(),
                ),
                initialValue: selectedAwayTeamId,
                items: tournament.teams.map((team) {
                  return DropdownMenuItem(
                    value: team.id,
                    child: Text(team.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    selectedAwayTeamId = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: selectedHomeTeamId != null && 
                         selectedAwayTeamId != null &&
                         selectedHomeTeamId != selectedAwayTeamId
                  ? () {
                      _addNewMatch(tournament, selectedHomeTeamId!, selectedAwayTeamId!);
                      Navigator.of(context).pop();
                    }
                  : null,
              child: const Text('Adicionar Partida'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _addNewMatch(Tournament tournament, String homeTeamId, String awayTeamId) {
    final newMatchNumber = tournament.matches.length + 1;
    final baseId = DateTime.now().millisecondsSinceEpoch;
    
    final newMatch = TournamentMatch(
      id: 'match_${newMatchNumber}_$baseId',
      homeTeamId: homeTeamId,
      awayTeamId: awayTeamId,
      matchNumber: newMatchNumber,
      status: TournamentMatchStatus.scheduled,
    );
    
    final updatedMatches = [...tournament.matches, newMatch];
    final updatedTournament = tournament.copyWith(matches: updatedMatches);
    
    // Atualizar localmente
    setState(() {
      final index = _localTournaments.indexWhere((t) => t.id == tournament.id);
      if (index != -1) {
        _localTournaments[index] = updatedTournament;
      }
    });
    
    // Salvar no Firebase
    _scheduleFirebaseUpdate(updatedTournament);
    
    // Mostrar notificação
    final homeTeam = tournament.teams.firstWhere((t) => t.id == homeTeamId);
    final awayTeam = tournament.teams.firstWhere((t) => t.id == awayTeamId);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nova partida adicionada: ${homeTeam.name} vs ${awayTeam.name}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Mostra dialog para capturar foto do time vencedor
  void _showWinnerPhotoDialog(Tournament tournament) {
    final winner = tournament.teams.firstWhere(
      (team) => team.id == tournament.championTeamId,
      orElse: () => tournament.teams.first,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.camera_alt, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Foto do Campeão',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 48,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Campeão: ${winner.name}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${winner.points} pontos',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Reuna o time campeão e capture o momento da vitória!',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          SportActionButton(
            label: 'Tirar Foto',
            icon: Icons.camera_alt,
            onPressed: () {
              Navigator.of(context).pop();
              _captureWinnerPhoto(tournament);
            },
          ),
        ],
      ),
    );
  }

  /// Captura foto do time vencedor
  Future<void> _captureWinnerPhoto(Tournament tournament) async {
    try {
      
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Processando foto...'),
            ],
          ),
        ),
      );

      // Capturar e converter foto para base64
      final String? photoBase64 = await PhotoService.captureWinnerPhotoAsBase64();
      
      // Fechar loading
      if (mounted) Navigator.of(context).pop();
      
      if (photoBase64 != null) {
        // Atualizar torneio com a foto
        final updatedTournament = tournament.copyWith(
          winnerPhotoBase64: photoBase64,
          photoTakenAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Atualizar localmente
        setState(() {
          final index = _localTournaments.indexWhere((t) => t.id == tournament.id);
          if (index != -1) {
            _localTournaments[index] = updatedTournament;
          }
        });

        // Salvar no Firebase
        _scheduleFirebaseUpdate(updatedTournament);

        // Mostrar sucesso
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🏆 Foto do campeão salva com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        
      } else {
      }
      
    } catch (e) {
      // Fechar loading se ainda estiver aberto
      if (mounted) {
        try {
          Navigator.of(context).pop();
        } catch (_) {}
      }
      
      
      // Mostrar erro
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao capturar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  /// Compartilha os times do torneio
  Future<void> _shareTournamentTeams(Tournament tournament) async {
    try {
      await ShareService.shareTournamentTeamsOnWhatsApp(tournament);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao compartilhar times: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  /// Baixa a foto do time vencedor
  Future<void> _downloadWinnerPhoto(Tournament tournament) async {
    try {
      
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Salvando foto...'),
            ],
          ),
        ),
      );
      
      final success = await ShareService.downloadWinnerPhoto(tournament);
      
      // Fechar loading
      if (mounted) Navigator.of(context).pop();
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📤 Foto compartilhada! Siga as instruções para salvar.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
      
    } catch (e) {
      // Fechar loading se ainda estiver aberto
      if (mounted) {
        try {
          Navigator.of(context).pop();
        } catch (_) {}
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao baixar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  /// Compartilha a foto do time vencedor
  Future<void> _shareWinnerPhoto(Tournament tournament) async {
    try {
      await ShareService.shareWinnerPhoto(tournament);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao compartilhar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  /// Compartilha torneio no Instagram Stories
  Future<void> _shareToInstagramStory(Tournament tournament) async {
    try {
      
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Gerando imagem para Stories...'),
            ],
          ),
        ),
      );
      
      await InstagramService.shareAsInstagramStory(tournament);
      
      // Fechar loading
      if (mounted) Navigator.of(context).pop();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📤 Story compartilhado no Instagram!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
    } catch (e) {
      // Fechar loading se ainda estiver aberto
      if (mounted) {
        try {
          Navigator.of(context).pop();
        } catch (_) {}
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao compartilhar Story: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
  
  /// Compartilha torneio no Instagram Post
  Future<void> _shareToInstagramPost(Tournament tournament) async {
    try {
      
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Gerando imagem para Feed...'),
            ],
          ),
        ),
      );
      
      await InstagramService.shareAsInstagramPost(tournament);
      
      // Fechar loading
      if (mounted) Navigator.of(context).pop();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📤 Post compartilhado no Instagram!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
    } catch (e) {
      // Fechar loading se ainda estiver aberto
      if (mounted) {
        try {
          Navigator.of(context).pop();
        } catch (_) {}
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao compartilhar Post: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Manipula as ações do menu do torneio
  void _handleTournamentMenuAction(String action, Tournament tournament) {
    switch (action) {
      case 'share_teams':
        _shareTournamentTeams(tournament);
        break;
      case 'save_photo':
        _downloadWinnerPhoto(tournament);
        break;
      case 'share_photo':
        _shareWinnerPhoto(tournament);
        break;
      case 'instagram_story':
        _shareToInstagramStory(tournament);
        break;
      case 'instagram_post':
        _shareToInstagramPost(tournament);
        break;
    }
  }

  void _toggleTournamentExpansion(String tournamentId) {
    setState(() {
      expandedTournaments[tournamentId] = !(expandedTournaments[tournamentId] ?? false);
      // Se está colapsando, remover a partida selecionada
      if (!(expandedTournaments[tournamentId] ?? false)) {
        selectedMatches.remove(tournamentId);
      }
    });
  }

  void _selectMatch(String tournamentId, int matchIndex) {
    setState(() {
      // Se a partida já está selecionada, recolher (remover seleção)
      if (selectedMatches[tournamentId] == matchIndex) {
        selectedMatches.remove(tournamentId);
      } else {
        selectedMatches[tournamentId] = matchIndex;
      }
    });
  }

  void _onEventsAdded(Tournament tournament, TournamentMatch match, List<TournamentMatchEvent> events) {
    
    // Adicionar todos os eventos à partida
    final updatedEvents = [...match.events, ...events];
    
    // Atualizar pontuação baseado nos eventos de gol
    int homeScore = match.homeScore;
    int awayScore = match.awayScore;
    
    for (final event in events) {
      
      if (event.type == TournamentMatchEventType.goal) {
        if (event.teamId == match.homeTeamId) {
          homeScore++;
        } else {
          awayScore++;
        }
      } else {
      }
    }
    
    final updatedMatch = match.copyWith(
      events: updatedEvents, 
      homeScore: homeScore, 
      awayScore: awayScore
    );
    
    _onMatchUpdated(tournament, updatedMatch);
  }

  void _onMatchUpdated(Tournament tournament, TournamentMatch updatedMatch) {
    
    // Atualizar partida no torneio
    final updatedMatches = tournament.matches.map((match) {
      return match.id == updatedMatch.id ? updatedMatch : match;
    }).toList();

    Tournament updatedTournament = tournament.copyWith(matches: updatedMatches);
    
    // Se a partida foi finalizada, atualizar estatísticas dos times
    if (updatedMatch.status == TournamentMatchStatus.finished) {
      updatedTournament = _updateTeamStatsAfterMatch(updatedTournament, updatedMatch);
      
      // Verificar se todas as partidas foram finalizadas para finalizar o torneio
      updatedTournament = _checkAndFinishTournamentIfComplete(updatedTournament);
    }
    
    // Update local tournaments immediately for responsive UI
    setState(() {
      final index = _localTournaments.indexWhere((t) => t.id == tournament.id);
      if (index != -1) {
        _localTournaments[index] = updatedTournament;
      }
    });
    
    // Schedule Firebase update (throttled)
    _scheduleFirebaseUpdate(updatedTournament);
  }
  
  void _scheduleFirebaseUpdate(Tournament tournament) {
    final now = DateTime.now();
    
    // Cancel existing timer if any
    _updateTimer?.cancel();
    
    // Schedule update after delay
    _updateTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        Modular.get<TournamentCubit>().updateTournament(tournament);
      }
    });
    
    // Also update immediately if it's been a while since last update
    if (_lastUpdateTime == null || now.difference(_lastUpdateTime!) > _updateThrottle) {
      _lastUpdateTime = now;
      Modular.get<TournamentCubit>().updateTournament(tournament);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Torneios'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                expandedTournaments.clear();
                selectedMatches.clear();
              });
            },
            icon: const Icon(Icons.unfold_less),
            tooltip: 'Recolher Todos',
          ),
          IconButton(
            onPressed: _loadTournaments,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              // Navegar para a página de seleção de jogadores para criar novo torneio
              Modular.to.pushNamed('/tournament/');
            },
            icon: const Icon(Icons.add),
            tooltip: 'Criar Novo Torneio',
          ),
        ],
      ),
      body: BlocConsumer<TournamentCubit, CubitState>(
        bloc: Modular.get<TournamentCubit>(),
        listener: (context, state) {
          state.whenError((message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.red,
              ),
            );
          });
          
          // Cache tournaments locally when loaded
          if (state.isSuccess) {
            final tournaments = CubitStateHelper.getList<Tournament>(state);
            setState(() {
              _localTournaments = List.from(tournaments);
              // Keep only existing tournaments expanded
              final existingIds = tournaments.map((t) => t.id).toSet();
              expandedTournaments.removeWhere((id, _) => !existingIds.contains(id));
              selectedMatches.removeWhere((id, _) => !existingIds.contains(id));
            });
          }
        },
        builder: (context, state) {
          return state.when(
            empty: () => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_soccer, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum torneio encontrado',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text('Crie um novo torneio para começar'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Modular.to.pushNamed('/tournament/'),
                    child: const Text('Criar Torneio'),
                  ),
                ],
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            success: (data) {
              final tournaments = CubitStateHelper.getList<Tournament>(state);
              
              if (tournaments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sports_soccer, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum torneio encontrado',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      const Text('Crie um novo torneio para começar'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Modular.to.pushNamed('/tournament/'),
                        child: const Text('Criar Torneio'),
                      ),
                    ],
                  ),
                );
              }

              // Use local tournaments for display to avoid constant rebuilds
              return RefreshIndicator(
                onRefresh: () async => _loadTournaments(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _localTournaments.isNotEmpty ? _localTournaments.length : tournaments.length,
                  itemBuilder: (context, index) {
                    final tournamentsToShow = _localTournaments.isNotEmpty ? _localTournaments : tournaments;
                    final tournament = tournamentsToShow[index];
                    final isExpanded = expandedTournaments[tournament.id] ?? false;
                    final selectedMatchIndex = selectedMatches[tournament.id];

                    return _buildTournamentCard(tournament, isExpanded, selectedMatchIndex);
                  },
                ),
              );
            },
            error: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text('Erro ao carregar torneios', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadTournaments, child: const Text('Tentar Novamente')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTournamentCard(Tournament tournament, bool isExpanded, int? selectedMatchIndex) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isExpanded ? 8 : 2,
      child: Column(
        children: [
          // Header do torneio
          InkWell(
            onTap: () => _toggleTournamentExpansion(tournament.id!),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(tournament.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(tournament.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Tournament info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tournament.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${tournament.teams.length} times • ${tournament.matches.length} partidas',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '${tournament.date.day}/${tournament.date.month}/${tournament.date.year}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Menu e expand icon
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: Colors.grey.shade600,
                        ),
                        onSelected: (String value) {
                          _handleTournamentMenuAction(value, tournament);
                        },
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem<String>(
                            value: 'share_teams',
                            child: Row(
                              children: [
                                Icon(Icons.share, size: 18),
                                SizedBox(width: 8),
                                Text('Compartilhar Times'),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          const PopupMenuItem<String>(
                            value: 'instagram_story',
                            child: Row(
                              children: [
                                Icon(Icons.auto_stories, size: 18, color: Color(0xFFE4405F)),
                                SizedBox(width: 8),
                                Text('Instagram Story'),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'instagram_post',
                            child: Row(
                              children: [
                                Icon(Icons.photo_camera, size: 18, color: Color(0xFFE4405F)),
                                SizedBox(width: 8),
                                Text('Instagram Post'),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          if (tournament.status == TournamentStatus.finished &&
                              tournament.winnerPhotoBase64 != null &&
                              tournament.winnerPhotoBase64!.isNotEmpty) ...[
                            const PopupMenuItem<String>(
                              value: 'save_photo',
                              child: Row(
                                children: [
                                  Icon(Icons.download, size: 18),
                                  SizedBox(width: 8),
                                  Text('Salvar Foto'),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'share_photo',
                              child: Row(
                                children: [
                                  Icon(Icons.share, size: 18),
                                  SizedBox(width: 8),
                                  Text('Compartilhar Foto'),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Expanded content
          if (isExpanded) ...[
            const Divider(height: 1),
            _buildExpandedContent(tournament, selectedMatchIndex),
          ],
        ],
      ),
    );
  }

  Widget _buildExpandedContent(Tournament tournament, int? selectedMatchIndex) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final contentPadding = isSmallScreen ? 12.0 : 16.0;
    final spacing = isSmallScreen ? 12.0 : 16.0;

    // Sem scroll interno: o ListView/ScrollView externo da página fará o scroll
    return Container(
      padding: EdgeInsets.all(contentPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto do vencedor (se o torneio estiver finalizado)
          if (tournament.status == TournamentStatus.finished)
            _buildWinnerSection(tournament),

          // Tabela de classificação
          _buildStandingsTable(tournament),

          SizedBox(height: spacing),
          const Divider(),
          SizedBox(height: spacing),

          // Estatísticas do torneio (artilheiros e assistentes)
          _buildTournamentStatistics(tournament),

          SizedBox(height: spacing),
          const Divider(),
          SizedBox(height: spacing),

          // Lista de partidas com botão para adicionar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Partidas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 14.0 : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (tournament.status != TournamentStatus.finished)
                ElevatedButton.icon(
                  onPressed: () => _showAddMatchDialog(tournament),
                  icon: Icon(Icons.add, size: isSmallScreen ? 14 : 16),
                  label: Text(
                    'Adicionar',
                    style: TextStyle(fontSize: isSmallScreen ? 10.0 : 12.0),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 8 : 12,
                      vertical: isSmallScreen ? 6 : 8,
                    ),
                    minimumSize: Size.zero,
                  ),
                ),
            ],
          ),
          SizedBox(height: spacing * 0.75),

          if (tournament.matches.isEmpty)
            Text(
              'Nenhuma partida criada ainda',
              style: TextStyle(fontSize: isSmallScreen ? 12.0 : 14.0),
            )
          else
            _buildMatchesList(tournament, selectedMatchIndex),
        ],
      ),
    );
  }

  Widget _buildWinnerSection(Tournament tournament) {
    final winner = tournament.teams.firstWhere(
      (team) => team.id == tournament.championTeamId,
      orElse: () => TournamentService.determineWinner(tournament.teams)!,
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🏆 Campeão',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        
        SportCard(
          useGradient: true,
          child: Column(
            children: [
              // Informações do time vencedor
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.black,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          winner.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${winner.points} pontos • ${winner.wins}V ${winner.draws}E ${winner.losses}D',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          'Saldo: ${winner.goalDifference >= 0 ? '+' : ''}${winner.goalDifference}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Seção da foto
              if (tournament.winnerPhotoBase64 != null && tournament.winnerPhotoBase64!.isNotEmpty) ...[
                // Foto existente (base64)
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      PhotoService.base64ToBytes(tournament.winnerPhotoBase64!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppTheme.surfaceDark,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: AppTheme.errorColor,
                                  size: 32,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Erro ao carregar foto',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (tournament.photoTakenAt != null)
                  Text(
                    'Foto tirada em ${tournament.photoTakenAt!.day}/${tournament.photoTakenAt!.month}/${tournament.photoTakenAt!.year}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 12),
                
                // Botão para tirar nova foto
                SportActionButton(
                  label: 'Tirar Nova Foto',
                  icon: Icons.camera_alt,
                  onPressed: () => _captureWinnerPhoto(tournament),
                  isExpanded: true,
                ),
              ] else ...[
                // Sem foto - mostrar botão para tirar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 48,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Capture o momento da vitória!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tire uma foto do time campeão',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      SportActionButton(
                        label: 'Tirar Foto',
                        icon: Icons.camera_alt,
                        onPressed: () => _showWinnerPhotoDialog(tournament),
                        isExpanded: true,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStandingsTable(Tournament tournament) {
    // Ordenar times por pontos, saldo de gols, gols marcados
    final sortedTeams = [...tournament.teams];
    sortedTeams.sort((a, b) {
      if (a.points != b.points) return b.points.compareTo(a.points);
      if (a.goalDifference != b.goalDifference) return b.goalDifference.compareTo(a.goalDifference);
      return b.goalsScored.compareTo(a.goalsScored);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Classificação',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmallWidth = constraints.maxWidth < 300;
                    final columnWidth = isSmallWidth ? 24.0 : 30.0;
                    final fontSize = isSmallWidth ? 10.0 : 12.0;
                    
                    return Row(
                      children: [
                        SizedBox(
                          width: columnWidth,
                          child: Text(
                            '#',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: fontSize,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Time',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: fontSize,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: columnWidth,
                          child: Text(
                            'PTS',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: fontSize,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          width: columnWidth,
                          child: Text(
                            'J',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: fontSize,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          width: columnWidth,
                          child: Text(
                            'SG',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: fontSize,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              // Rows
              ...sortedTeams.asMap().entries.map((entry) {
                final position = entry.key + 1;
                final team = entry.value;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isSmallWidth = constraints.maxWidth < 300;
                      final columnWidth = isSmallWidth ? 24.0 : 30.0;
                      final fontSize = isSmallWidth ? 10.0 : 12.0;
                      
                      return Row(
                        children: [
                          SizedBox(
                            width: columnWidth,
                            child: Text(
                              '$position°',
                              style: TextStyle(fontSize: fontSize),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              team.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: fontSize,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            width: columnWidth,
                            child: Text(
                              '${team.points}',
                              style: TextStyle(fontSize: fontSize),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            width: columnWidth,
                            child: Text(
                              '${team.matchesPlayed}',
                              style: TextStyle(fontSize: fontSize),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            width: columnWidth,
                            child: Text(
                              '${team.goalDifference >= 0 ? '+' : ''}${team.goalDifference}',
                              style: TextStyle(fontSize: fontSize),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTournamentStatistics(Tournament tournament) {
    // Calcular artilheiros e assistentes
    final scorers = <String, int>{}; // playerId -> goals
    final assists = <String, int>{}; // playerId -> assists
    final playerNames = <String, String>{}; // playerId -> playerName
    
    
    // Processar todos os eventos de gol e assistência
    for (final match in tournament.matches) {
      for (final event in match.events) {
        final playerId = event.playerId;
        
        if (playerId.isNotEmpty) {
          // Find player name by searching through all teams
          String? playerName;
          for (final team in tournament.teams) {
            // Buscar por ID real primeiro
            Player? player = team.players.where((p) => p.id == playerId).firstOrNull;
            
            // Se não encontrou por ID real, buscar por ID baseado no nome
            player ??= team.players.where((p) => 
              (p.id == null || p.id!.isEmpty) && 
              p.name.replaceAll(' ', '_').toLowerCase() == playerId
            ).firstOrNull;
            
            // Também verificar nas reservas
            player ??= team.reserves.where((p) => p.id == playerId).firstOrNull;
            
            player ??= team.reserves.where((p) => 
              (p.id == null || p.id!.isEmpty) && 
              p.name.replaceAll(' ', '_').toLowerCase() == playerId
            ).firstOrNull;
            
            if (player != null) {
              playerName = player.name;
              break;
            }
          }
          
          if (playerName != null) {
            playerNames[playerId] = playerName;
            
            if (event.type == TournamentMatchEventType.goal) {
              final newCount = (scorers[playerId] ?? 0) + 1;
              scorers[playerId] = newCount;
            } else if (event.type == TournamentMatchEventType.assist) {
              final newCount = (assists[playerId] ?? 0) + 1;
              assists[playerId] = newCount;
            }
          }
        }
      }
    }
    
    // Ordenar artilheiros (maior número de gols primeiro)
    final topScorers = scorers.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Ordenar assistentes (maior número de assistências primeiro)
    final topAssists = assists.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estatísticas',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Artilheiros
            Expanded(
              child: _buildStatColumn(
                'Artilheiros',
                topScorers.take(5).map((entry) => {
                  'name': playerNames[entry.key] ?? 'Desconhecido',
                  'value': '${entry.value} gols',
                }).toList(),
              ),
            ),
            const SizedBox(width: 16),
            // Assistentes
            Expanded(
              child: _buildStatColumn(
                'Assistentes',
                topAssists.take(5).map((entry) => {
                  'name': playerNames[entry.key] ?? 'Desconhecido',
                  'value': '${entry.value} assist.',
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildStatColumn(String title, List<Map<String, String>> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: stats.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Nenhum registro',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                )
              : Column(
                  children: stats.asMap().entries.map((entry) {
                    final index = entry.key;
                    final stat = entry.value;
                    final isFirst = index == 0;
                    final isLast = index == stats.length - 1;
                    
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isFirst ? Colors.amber.shade50 : null,
                        border: !isLast
                            ? Border(bottom: BorderSide(color: Colors.grey.shade200))
                            : null,
                        borderRadius: isFirst && isLast
                            ? BorderRadius.circular(8)
                            : isFirst
                                ? const BorderRadius.vertical(top: Radius.circular(8))
                                : isLast
                                    ? const BorderRadius.vertical(bottom: Radius.circular(8))
                                    : null,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            child: Text(
                              '${index + 1}°',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isFirst ? FontWeight.bold : FontWeight.normal,
                                color: isFirst ? Colors.amber.shade700 : Colors.grey.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              stat['name'] ?? 'Desconhecido',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isFirst ? FontWeight.bold : FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            stat['value'] ?? '0',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isFirst ? FontWeight.bold : FontWeight.normal,
                              color: isFirst ? Colors.amber.shade700 : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildMatchesList(Tournament tournament, int? selectedMatchIndex) {
    return Column(
      children: tournament.matches.asMap().entries.map((entry) {
        final index = entry.key;
        final match = entry.value;
        final isSelected = selectedMatchIndex == index;
        
        return _buildMatchCard(tournament, match, index, isSelected);
      }).toList(),
    );
  }

  Widget _buildMatchCard(Tournament tournament, TournamentMatch match, int index, bool isSelected) {
    final homeTeam = tournament.teams.firstWhere(
      (team) => team.id == match.homeTeamId,
      orElse: () => TournamentTeam(id: '', name: 'Time não encontrado', players: [], reserves: []),
    );
    
    final awayTeam = tournament.teams.firstWhere(
      (team) => team.id == match.awayTeamId,
      orElse: () => TournamentTeam(id: '', name: 'Time não encontrado', players: [], reserves: []),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected 
          ? Theme.of(context).colorScheme.surfaceContainerHigh.withValues(alpha: 0.7)
          : Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: isSelected 
          ? Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              width: 1,
            )
          : null,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => _selectMatch(tournament.id!, index),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Match info
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getMatchStatusColor(match.status),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Partida ${match.matchNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Teams and score
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            homeTeam.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${match.homeScore} - ${match.awayScore}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            awayTeam.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Time
                  Text(
                    '${match.elapsedMinutes.toString().padLeft(2, '0')}:${match.elapsedSeconds.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isSelected ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          // Match management interface
          if (isSelected) ...[
            const Divider(height: 1),
            _buildMatchManagement(tournament, match),
          ],
        ],
      ),
    );
  }

  Widget _buildMatchManagement(Tournament tournament, TournamentMatch match) {
    final homeTeam = tournament.teams.firstWhere((team) => team.id == match.homeTeamId);
    final awayTeam = tournament.teams.firstWhere((team) => team.id == match.awayTeamId);

    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Match Timer
          MatchTimer(
            match: match,
            onMatchUpdated: (updatedMatch) => _onMatchUpdated(tournament, updatedMatch),
            onMatchFinished: () {
              // Handle match finished
              final finishedMatch = match.copyWith(
                status: TournamentMatchStatus.finished,
                endTime: DateTime.now(),
              );
              _onMatchUpdated(tournament, finishedMatch);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Partida finalizada e estatísticas atualizadas!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          
          const SizedBox(height: 12),
          
          // Match Events
          MatchEvents(
            match: match,
            homeTeam: homeTeam,
            awayTeam: awayTeam,
            onEventAdded: (updatedMatch, events) => _onEventsAdded(tournament, updatedMatch, events),
            currentMinute: match.elapsedMinutes,
            currentSecond: match.elapsedSeconds,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(TournamentStatus status) {
    switch (status) {
      case TournamentStatus.setup:
        return Colors.orange;
      case TournamentStatus.inProgress:
        return Colors.blue;
      case TournamentStatus.finished:
        return Colors.green;
    }
  }

  String _getStatusText(TournamentStatus status) {
    switch (status) {
      case TournamentStatus.setup:
        return 'Configuração';
      case TournamentStatus.inProgress:
        return 'Em Andamento';
      case TournamentStatus.finished:
        return 'Finalizado';
    }
  }

  Color _getMatchStatusColor(TournamentMatchStatus status) {
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
}