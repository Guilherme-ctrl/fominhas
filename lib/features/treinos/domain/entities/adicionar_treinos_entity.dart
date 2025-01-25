import 'package:equatable/equatable.dart';

class AdicionarTreinosEntity extends Equatable {
  final String data;
  final String descricao;

  AdicionarTreinosEntity({required this.data, required this.descricao});

  @override
  List<Object?> get props => [data, descricao];
}
