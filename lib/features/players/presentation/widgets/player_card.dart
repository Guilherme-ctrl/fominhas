import 'package:flutter/material.dart';
import '../../domain/entities/player.dart';

class PlayerCard extends StatelessWidget {
  final Player player;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PlayerCard({
    super.key,
    required this.player,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Jersey number circle
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${player.jerseyNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Player info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getPositionName(player.position),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatChip(
                          icon: Icons.sports_soccer,
                          label: '${player.stats.goals}',
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        _buildStatChip(
                          icon: Icons.assist_walker,
                          label: '${player.stats.assists}',
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        _buildStatChip(
                          icon: Icons.games,
                          label: '${player.stats.matchesPlayed}',
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Action buttons
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Editar'),
                      dense: true,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Excluir', style: TextStyle(color: Colors.red)),
                      dense: true,
                    ),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
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

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}