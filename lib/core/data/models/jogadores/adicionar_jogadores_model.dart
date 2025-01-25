import 'package:equatable/equatable.dart';

class AdicionarJogadoresModel extends Equatable {
  final String nome;
  final int numero;
  final String email;
  final String documento;
  final int presencas;
  final int faltas;

  AdicionarJogadoresModel({
    required this.nome,
    required this.numero,
    required this.email,
    required this.documento,
    this.presencas = 0, // Inicializa presenças com 0
    this.faltas = 0, // Inicializa faltas com 0
  });

  Map<String, dynamic> toMap() => {
        'nome': nome,
        'numero': numero,
        'email': email,
        'documento': documento,
        'presencas': presencas,
        'faltas': faltas,
      };

  @override
  List<Object?> get props => [nome, numero, email, documento, presencas, faltas];
}
