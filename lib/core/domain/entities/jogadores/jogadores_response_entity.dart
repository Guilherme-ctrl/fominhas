import 'package:equatable/equatable.dart';

class JogadoresResponseEntity extends Equatable {
  final String id;
  final String nome;
  final int presencas;
  final int faltas;
  final String email;
  final String documento;
  final int numero;

  JogadoresResponseEntity(
      {required this.id,
      required this.nome,
      required this.presencas,
      required this.faltas,
      required this.email,
      required this.documento,
      required this.numero});

  @override
  List<Object?> get props => [id, nome, presencas, faltas, email, documento, numero];
}
