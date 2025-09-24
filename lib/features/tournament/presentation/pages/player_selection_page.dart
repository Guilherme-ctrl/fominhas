import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../../core/state/cubit_state.dart';
import '../../../../core/extensions/cubit_state_extensions.dart';
import '../../../players/domain/entities/player.dart';
import '../../../players/presentation/cubit/players_cubit.dart';
import '../../domain/services/tournament_service.dart';
import 'team_review_page.dart';

class PlayerSelectionPage extends StatefulWidget {
  const PlayerSelectionPage({super.key});

  @override
  State<PlayerSelectionPage> createState() => _PlayerSelectionPageState();
}

class _PlayerSelectionPageState extends State<PlayerSelectionPage> {
  final Set<String> selectedPlayerIds = <String>{};
  final TextEditingController tournamentNameController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  int selectedTeamCount = 2;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Carregar jogadores disponíveis
    Modular.get<PlayersCubit>().loadPlayers();
  }

  @override
  void dispose() {
    tournamentNameController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _onPlayerToggled(Player player) {
    setState(() {
      if (selectedPlayerIds.contains(player.id)) {
        selectedPlayerIds.remove(player.id);
      } else {
        selectedPlayerIds.add(player.id!);
      }
    });
  }

  void _selectAllPlayers(List<Player> players) {
    setState(() {
      for (final player in players) {
        if (player.id != null) {
          selectedPlayerIds.add(player.id!);
        }
      }
    });
  }

  void _deselectAllPlayers() {
    setState(() {
      selectedPlayerIds.clear();
    });
  }

  void _createTournament(List<Player> allPlayers) {
    
    final minPlayers = selectedTeamCount * 4;
    
    if (selectedPlayerIds.length < minPlayers) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selecione pelo menos $minPlayers jogadores para criar $selectedTeamCount times'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (tournamentNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite um nome para o torneio'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }


    final selectedPlayers = allPlayers
        .where((player) => selectedPlayerIds.contains(player.id))
        .toList();
    

    try {
      final teams = TournamentService.createBalancedTeams(selectedPlayers, selectedTeamCount);
      
      for (int i = 0; i < teams.length; i++) {
      }
      
      // Navegar para tela de revisão dos times
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TeamReviewPage(
            tournamentName: tournamentNameController.text.trim(),
            teams: teams,
          ),
        ),
      ).then((result) {
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar torneio: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildPlayerCard(Player player, bool isSelected) {
    return Card(
      elevation: isSelected ? 4 : 2,
      color: isSelected ? Colors.blue.shade50 : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getPositionColor(player.position),
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
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(_getPositionName(player.position)),
        trailing: isSelected 
            ? const Icon(Icons.check_circle, color: Colors.blue)
            : const Icon(Icons.radio_button_unchecked),
        onTap: () => _onPlayerToggled(player),
      ),
    );
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

  Widget _buildPositionSummary(List<Player> selectedPlayers) {
    final goalkeepers = selectedPlayers.where((p) => p.position == PlayerPosition.goleiro).length;
    final defenders = selectedPlayers.where((p) => p.position == PlayerPosition.fixo).length;
    final wings = selectedPlayers.where((p) => p.position == PlayerPosition.ala).length;
    final pivots = selectedPlayers.where((p) => p.position == PlayerPosition.pivo).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumo da Seleção (${selectedPlayers.length}/${selectedPlayers.length >= selectedTeamCount * 4 ? "✓" : "${selectedTeamCount * 4}"})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: selectedPlayers.length >= selectedTeamCount * 4 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPositionCount('G', goalkeepers, Colors.green),
                _buildPositionCount('F', defenders, Colors.red),
                _buildPositionCount('A', wings, Colors.blue),
                _buildPositionCount('P', pivots, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionCount(String position, int count, Color color) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color,
          radius: 16,
          child: Text(
            position,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleção de Jogadores'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<PlayersCubit, CubitState>(
        bloc: Modular.get<PlayersCubit>(),
        listener: (context, state) {
          state.whenError((message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.red,
              ),
            );
          });
        },
        builder: (context, state) {
          return state.when(
            empty: () => const Center(
              child: Text('Carregue os jogadores'),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            success: (data) {
              final players = CubitStateHelper.getList<Player>(state);
              
              // Filtrar jogadores pela pesquisa
              final filteredPlayers = players.where((player) {
                if (searchQuery.isEmpty) return true;
                return player.name.toLowerCase().contains(searchQuery.toLowerCase());
              }).toList();
              
              final selectedPlayers = players
                  .where((player) => selectedPlayerIds.contains(player.id))
                  .toList();

              return Column(
              children: [
                // Campo para nome do torneio
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: tournamentNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Torneio',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.sports_soccer),
                    ),
                  ),
                ),
                
                // Barra de pesquisa
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      labelText: 'Pesquisar jogadores...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Botões de seleção
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _selectAllPlayers(filteredPlayers),
                          icon: const Icon(Icons.select_all, size: 18),
                          label: const Text('Selecionar Todos'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: selectedPlayerIds.isNotEmpty ? _deselectAllPlayers : null,
                          icon: const Icon(Icons.clear_all, size: 18),
                          label: const Text('Limpar Seleção'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Seleção da quantidade de times
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quantidade de Times',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              for (int i = 2; i <= 6; i++)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2),
                                    child: ChoiceChip(
                                      label: Text('$i'),
                                      selected: selectedTeamCount == i,
                                      onSelected: (selected) {
                                        if (selected) {
                                          setState(() {
                                            selectedTeamCount = i;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Mínimo: ${selectedTeamCount * 4} jogadores (4 por time)',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Resumo da seleção
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildPositionSummary(selectedPlayers),
                ),

                // Lista de jogadores
                Expanded(
                  child: filteredPlayers.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhum jogador encontrado',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: filteredPlayers.length,
                          itemBuilder: (context, index) {
                            final player = filteredPlayers[index];
                            final isSelected = selectedPlayerIds.contains(player.id);
                            return _buildPlayerCard(player, isSelected);
                          },
                        ),
                ),

                // Botão para criar torneio
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedPlayerIds.length >= selectedTeamCount * 4
                          ? () {
                              _createTournament(players);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Criar Torneio (${selectedPlayerIds.length}/${selectedTeamCount * 4}+)',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            );
            },
            error: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar jogadores',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Modular.get<PlayersCubit>().loadPlayers(),
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}