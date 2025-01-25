import 'package:equatable/equatable.dart';

class AdicionarTreinosModel extends Equatable {
  final String data;
  final String descricao;

  AdicionarTreinosModel({required this.data, required this.descricao});

  Map<String, dynamic> toMap() => {
        'data': data,
        'descricao': descricao,
        'presencas': [],
      };

  @override
  List<Object?> get props => [data, descricao];
}
