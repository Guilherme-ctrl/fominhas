import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/match.dart';

class MatchCard extends StatelessWidget {
  final Match match;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MatchCard({
    super.key,
    required this.match,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with date and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('dd/MM/yyyy - HH:mm').format(match.matchDate),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  Row(
                    children: [
                      _buildStatusChip(match.status),
                      const SizedBox(width: 8),
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
                ],
              ),
              const SizedBox(height: 16),
              
              // Teams and score
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Home team
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          match.homeTeam,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${match.homeScore}',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // VS separator
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Text(
                          'VS',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Icon(
                          Icons.sports_soccer,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                  
                  // Away team
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          match.awayTeam,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${match.awayScore}',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Venue
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      match.venue,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(MatchStatus status) {
    Color color;
    String label;
    
    switch (status) {
      case MatchStatus.scheduled:
        color = Colors.blue;
        label = 'Agendada';
        break;
      case MatchStatus.inProgress:
        color = Colors.orange;
        label = 'Em andamento';
        break;
      case MatchStatus.finished:
        color = Colors.green;
        label = 'Finalizada';
        break;
      case MatchStatus.cancelled:
        color = Colors.red;
        label = 'Cancelada';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}