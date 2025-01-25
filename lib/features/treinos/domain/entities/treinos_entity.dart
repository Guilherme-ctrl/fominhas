import 'package:equatable/equatable.dart';

class TreinosEntity extends Equatable {
  final String id;
  final String data;
  final String descricao;
  final List<dynamic> presenca;

  TreinosEntity({required this.data, required this.descricao, required this.presenca, required this.id});

  @override
  List<Object?> get props => [id, data, descricao, presenca];
}
