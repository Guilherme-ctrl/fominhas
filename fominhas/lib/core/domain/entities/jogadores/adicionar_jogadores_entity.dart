import 'package:equatable/equatable.dart';

class AdicionarJogadoresEntity extends Equatable {
  final String nome;
  final int numero;
  final String email;
  final String documento;
  final int presencas;
  final int faltas;

  AdicionarJogadoresEntity({
    required this.nome,
    required this.numero,
    required this.email,
    required this.documento,
    this.presencas = 0, // Inicializa presenças com 0
    this.faltas = 0, // Inicializa faltas com 0
  });

  @override
  List<Object?> get props => [nome, numero, email, documento, presencas, faltas];
}
