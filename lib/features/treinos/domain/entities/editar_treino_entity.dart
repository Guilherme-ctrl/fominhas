import 'package:equatable/equatable.dart';

class EditarTreinoEntity extends Equatable {
  final String descricao;
  final String data;
  final List<dynamic> presentes;

  EditarTreinoEntity(this.descricao, this.data, this.presentes);

  @override
  List<Object?> get props => [descricao, data, presentes];
}
