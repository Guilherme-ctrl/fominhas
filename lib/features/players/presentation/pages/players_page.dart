import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../../core/state/cubit_state.dart';
import '../../../../core/extensions/cubit_state_extensions.dart';
import '../../domain/entities/player.dart';
import '../cubit/players_cubit.dart';
import '../widgets/player_form_dialog.dart';
import '../widgets/player_card.dart';

class PlayersPage extends StatefulWidget {
  const PlayersPage({super.key});

  @override
  State<PlayersPage> createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Modular.get<PlayersCubit>().loadPlayers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jogadores'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: _showAddPlayerDialog)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar jogadores...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            Modular.get<PlayersCubit>().loadPlayers();
                          },
                        )
                        : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                setState(() {});
                if (value.isNotEmpty) {
                  Modular.get<PlayersCubit>().searchPlayers(value);
                } else {
                  Modular.get<PlayersCubit>().loadPlayers();
                }
              },
            ),
          ),
          Expanded(
            child: BlocConsumer<PlayersCubit, CubitState>(
              bloc: Modular.get<PlayersCubit>(),
              listener: (context, state) {
                state.whenError((message) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
                });
              },
              builder: (context, state) {
                return state.when(
                  empty: () => const Center(child: Text('Carregue os jogadores')),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  success: (data) {
                    final players = CubitStateHelper.getList<Player>(state);
                    if (players.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('Nenhum jogador encontrado', style: TextStyle(fontSize: 18, color: Colors.grey)),
                            SizedBox(height: 8),
                            Text('Toque no + para adicionar o primeiro jogador', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: players.length,
                      itemBuilder: (context, index) {
                        final player = players[index];
                        return PlayerCard(
                          player: player,
                          onTap: () => _showPlayerDetailsDialog(player),
                          onEdit: () => _showEditPlayerDialog(player),
                          onDelete: () => _showDeleteConfirmDialog(player),
                        );
                      },
                    );
                  },
                  error:
                      (message) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text('Erro ao carregar jogadores', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text(message, style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(onPressed: () => Modular.get<PlayersCubit>().loadPlayers(), child: const Text('Tentar novamente')),
                          ],
                        ),
                      ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPlayerDialog() {
    showDialog(
      context: context,
      builder:
          (context) => PlayerFormDialog(
            onSave: (player) {
              Modular.get<PlayersCubit>().createPlayer(player);
            },
          ),
    );
  }

  void _showEditPlayerDialog(Player player) {
    showDialog(
      context: context,
      builder:
          (context) => PlayerFormDialog(
            player: player,
            onSave: (updatedPlayer) {
              Modular.get<PlayersCubit>().updatePlayer(updatedPlayer);
            },
          ),
    );
  }

  void _showPlayerDetailsDialog(Player player) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(player.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Posição: ${player.position}'),
                Text('Número: ${player.jerseyNumber}'),
                if (player.email != null) Text('Email: ${player.email}'),
                if (player.phone != null) Text('Telefone: ${player.phone}'),
                const SizedBox(height: 16),
                Text('Estatísticas:', style: Theme.of(context).textTheme.titleMedium),
                Text('Partidas: ${player.stats.matchesPlayed}'),
                Text('Gols: ${player.stats.goals}'),
                Text('Assistências: ${player.stats.assists}'),
                Text('Cartões Amarelos: ${player.stats.yellowCards}'),
                Text('Cartões Vermelhos: ${player.stats.redCards}'),
              ],
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar'))],
          ),
    );
  }

  void _showDeleteConfirmDialog(Player player) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar exclusão'),
            content: Text('Deseja realmente excluir o jogador ${player.name}?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (player.id != null) {
                    Modular.get<PlayersCubit>().deletePlayer(player.id!);
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Excluir'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
