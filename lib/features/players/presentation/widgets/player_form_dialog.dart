import 'package:flutter/material.dart';
import '../../domain/entities/player.dart';

class PlayerFormDialog extends StatefulWidget {
  final Player? player;
  final Function(Player) onSave;

  const PlayerFormDialog({super.key, this.player, required this.onSave});

  @override
  State<PlayerFormDialog> createState() => _PlayerFormDialogState();
}

class _PlayerFormDialogState extends State<PlayerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _jerseyNumberController = TextEditingController();

  PlayerPosition _selectedPosition = PlayerPosition.ala;
  final List<PlayerPosition> _positions = PlayerPosition.values;

  @override
  void initState() {
    super.initState();
    if (widget.player != null) {
      _nameController.text = widget.player!.name;
      _emailController.text = widget.player!.email ?? '';
      _phoneController.text = widget.player!.phone ?? '';
      _jerseyNumberController.text = widget.player!.jerseyNumber.toString();
      _selectedPosition = widget.player!.position;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.player == null ? 'Adicionar Jogador' : 'Editar Jogador'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nome *', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nome é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<PlayerPosition>(
                  initialValue: _selectedPosition,
                  decoration: const InputDecoration(labelText: 'Posição *', border: OutlineInputBorder()),
                  items:
                      _positions.map((position) {
                        return DropdownMenuItem(value: position, child: Text(_getPositionName(position)));
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPosition = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _jerseyNumberController,
                  decoration: const InputDecoration(labelText: 'Número da camisa *', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Número é obrigatório';
                    }
                    final number = int.tryParse(value);
                    if (number == null || number < 1 || number > 99) {
                      return 'Número deve estar entre 1 e 99';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Telefone', border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: _save, child: const Text('Salvar')),
      ],
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

  void _save() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final player = Player(
        id: widget.player?.id,
        name: _nameController.text.trim(),
        position: _selectedPosition,
        jerseyNumber: int.parse(_jerseyNumberController.text),
        email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        createdAt: widget.player?.createdAt ?? now,
        updatedAt: widget.player != null ? now : null,
        stats: widget.player?.stats ?? const PlayerStats(),
      );

      widget.onSave(player);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _jerseyNumberController.dispose();
    super.dispose();
  }
}
