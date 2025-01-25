import 'package:equatable/equatable.dart';

class EditarTreinoModel extends Equatable {
  final String descricao;
  final String data;
  final List<dynamic> presentes;

  EditarTreinoModel({required this.descricao, required this.data, required this.presentes});

  Map<String, dynamic> toMap() => {
        'data': data,
        'descricao': descricao,
        'presencas': presentes,
      };

  @override
  List<Object?> get props => [descricao, data, presentes];
}
