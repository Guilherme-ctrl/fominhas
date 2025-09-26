import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/match.dart';

class MatchFormDialog extends StatefulWidget {
  final Match? match;
  final Function(Match) onSave;

  const MatchFormDialog({
    super.key,
    this.match,
    required this.onSave,
  });

  @override
  State<MatchFormDialog> createState() => _MatchFormDialogState();
}

class _MatchFormDialogState extends State<MatchFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _homeTeamController = TextEditingController();
  final _awayTeamController = TextEditingController();
  final _venueController = TextEditingController();
  final _homeScoreController = TextEditingController();
  final _awayScoreController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  MatchStatus _selectedStatus = MatchStatus.scheduled;

  @override
  void initState() {
    super.initState();
    if (widget.match != null) {
      _homeTeamController.text = widget.match!.homeTeam;
      _awayTeamController.text = widget.match!.awayTeam;
      _venueController.text = widget.match!.venue;
      _homeScoreController.text = widget.match!.homeScore.toString();
      _awayScoreController.text = widget.match!.awayScore.toString();
      _selectedDate = widget.match!.matchDate;
      _selectedTime = TimeOfDay.fromDateTime(widget.match!.matchDate);
      _selectedStatus = widget.match!.status;
    } else {
      _homeScoreController.text = '0';
      _awayScoreController.text = '0';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.match == null ? 'Nova Partida' : 'Editar Partida'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Home team
                TextFormField(
                  controller: _homeTeamController,
                  decoration: const InputDecoration(
                    labelText: 'Time da Casa *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.home),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Time da casa é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Away team
                TextFormField(
                  controller: _awayTeamController,
                  decoration: const InputDecoration(
                    labelText: 'Time Visitante *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.sports_soccer),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Time visitante é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Venue
                TextFormField(
                  controller: _venueController,
                  decoration: const InputDecoration(
                    labelText: 'Local *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Local é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date picker
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data da Partida *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(_selectedDate),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Time picker
                InkWell(
                  onTap: _selectTime,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Horário *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    child: Text(
                      _selectedTime.format(context),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Status
                DropdownButtonFormField<MatchStatus>(
                  initialValue: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.flag),
                  ),
                  items: MatchStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(_getStatusLabel(status)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Scores (only show if status is not scheduled)
                if (_selectedStatus != MatchStatus.scheduled) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _homeScoreController,
                          decoration: const InputDecoration(
                            labelText: 'Gols Casa',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final score = int.tryParse(value);
                              if (score == null || score < 0) {
                                return 'Número inválido';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _awayScoreController,
                          decoration: const InputDecoration(
                            labelText: 'Gols Visitante',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final score = int.tryParse(value);
                              if (score == null || score < 0) {
                                return 'Número inválido';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _getStatusLabel(MatchStatus status) {
    switch (status) {
      case MatchStatus.scheduled:
        return 'Agendada';
      case MatchStatus.inProgress:
        return 'Em andamento';
      case MatchStatus.finished:
        return 'Finalizada';
      case MatchStatus.cancelled:
        return 'Cancelada';
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final matchDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final match = Match(
        id: widget.match?.id,
        homeTeam: _homeTeamController.text.trim(),
        awayTeam: _awayTeamController.text.trim(),
        venue: _venueController.text.trim(),
        matchDate: matchDateTime,
        status: _selectedStatus,
        homeScore: _selectedStatus == MatchStatus.scheduled ? 0 : int.parse(_homeScoreController.text.isEmpty ? '0' : _homeScoreController.text),
        awayScore: _selectedStatus == MatchStatus.scheduled ? 0 : int.parse(_awayScoreController.text.isEmpty ? '0' : _awayScoreController.text),
        createdAt: widget.match?.createdAt ?? now,
        updatedAt: widget.match != null ? now : null,
        events: widget.match?.events ?? [],
      );

      widget.onSave(match);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _homeTeamController.dispose();
    _awayTeamController.dispose();
    _venueController.dispose();
    _homeScoreController.dispose();
    _awayScoreController.dispose();
    super.dispose();
  }
}
