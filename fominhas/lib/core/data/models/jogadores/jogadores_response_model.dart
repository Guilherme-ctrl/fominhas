import 'package:equatable/equatable.dart';

import '../../../cast/try_cast.dart';

class JogadoresResponseModel extends Equatable {
  final String id;
  final String nome;
  final int presencas;
  final int faltas;
  final String email;
  final String documento;
  final int numero;

  JogadoresResponseModel(
      {required this.id,
      required this.nome,
      required this.presencas,
      required this.faltas,
      required this.email,
      required this.documento,
      required this.numero});

  factory JogadoresResponseModel.fromJson(String id, Map<String, dynamic> json) {
    return JogadoresResponseModel(
      id: id,
      nome: tryCast<String>(json['nome'], ""),
      presencas: tryCast<int>(json['presencas'], 0),
      faltas: tryCast<int>(json['faltas'], 0),
      email: tryCast<String>(json['email'], ""),
      documento: tryCast<String>(json['documento'], ""),
      numero: tryCast<int>(json['numero'], 0),
    );
  }

  @override
  List<Object?> get props => [id, nome, presencas, faltas, email, documento, numero];
}
