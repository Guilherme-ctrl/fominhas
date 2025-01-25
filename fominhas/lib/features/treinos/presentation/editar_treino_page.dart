import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:fominhas/core/cubit/get_jogadores_cubit.dart';
import 'package:fominhas/features/treinos/domain/entities/treinos_entity.dart';
import 'package:fominhas/features/treinos/presentation/cubit/editar_presenca_cubit.dart';
import 'package:fominhas/features/treinos/presentation/cubit/editar_treino_cubit.dart';
import 'package:fominhas/features/treinos/presentation/cubit/treino_by_id_cubit.dart';
import 'package:fominhas/features/widgets/date_picker/custom_date_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/state/cubit_state.dart';
import '../../widgets/loader/loader_widget.dart';

class EditarTreinoPage extends StatefulWidget {
  final String treinoId;

  const EditarTreinoPage({super.key, required this.treinoId});

  @override
  _EditarTreinoPageState createState() => _EditarTreinoPageState();
}

class _EditarTreinoPageState extends State<EditarTreinoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descricaoController = TextEditingController();
  final _cubitTreinoById = Modular.get<TreinoByIdCubit>();
  final _cubitJogadores = Modular.get<GetJogadoresCubit>();
  final _cubitEditarTreino = Modular.get<EditarTreinoCubit>();
  final _cubitEditarPresenca = Modular.get<EditarPresencaCubit>();
  // ignore: unused_field
  DateTime? _selectedDate;
  bool loading = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cubitJogadores.getJogadores();
      _cubitTreinoById.treinoById(widget.treinoId);
    });
    super.initState();
  }

  @override
  void dispose() {
    _cubitEditarTreino.presentes.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Editar Treino"),
          backgroundColor: Color(0xff018055),
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener(
                bloc: _cubitEditarPresenca,
                listener: (context, state) async {
                  if (loading) {
                    Modular.to.pop();
                    loading = false;
                  }
                  if (state is LoadingCubitState) {
                    setState(() {
                      loading = true;
                    });
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return LoaderWidget();
                      },
                    );
                  } else if (state is ErrorCubitState) {
                    if (loading) {
                      Modular.to.pop();
                      loading = false;
                    }
                    await Flushbar(
                      margin: EdgeInsets.all(8),
                      message: state.message,
                      titleColor: Colors.white,
                      flushbarPosition: FlushbarPosition.TOP,
                      flushbarStyle: FlushbarStyle.FLOATING,
                      reverseAnimationCurve: Curves.decelerate,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      forwardAnimationCurve: Curves.ease,
                      maxWidth: MediaQuery.of(context).size.width * .3,
                      backgroundColor: Colors.red,
                      isDismissible: true,
                      duration: Duration(seconds: 2),
                    ).show(context);
                  } else if (state is SuccessCubitState) {
                    if (loading) {
                      Modular.to.pop();
                      loading = false;
                    }
                    await Flushbar(
                      margin: EdgeInsets.all(8),
                      message: "Registrado com Sucesso",
                      titleColor: Colors.white,
                      flushbarPosition: FlushbarPosition.TOP,
                      flushbarStyle: FlushbarStyle.FLOATING,
                      reverseAnimationCurve: Curves.decelerate,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      forwardAnimationCurve: Curves.ease,
                      maxWidth: MediaQuery.of(context).size.width * .3,
                      backgroundColor: Colors.green,
                      isDismissible: true,
                      duration: Duration(seconds: 2),
                    ).show(context).then((_) {
                      Modular.to.pushNamedAndRemoveUntil("/home/", (_) => false);
                    });
                  }
                }),
            BlocListener(
                bloc: _cubitEditarTreino,
                listener: (context, state) async {
                  if (loading) {
                    Modular.to.pop();
                    loading = false;
                  }
                  if (state is LoadingCubitState) {
                    setState(() {
                      loading = true;
                    });
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return LoaderWidget();
                      },
                    );
                  } else if (state is ErrorCubitState) {
                    if (loading) {
                      Modular.to.pop();
                      loading = false;
                    }
                    await Flushbar(
                      margin: EdgeInsets.all(8),
                      message: state.message,
                      titleColor: Colors.white,
                      flushbarPosition: FlushbarPosition.TOP,
                      flushbarStyle: FlushbarStyle.FLOATING,
                      reverseAnimationCurve: Curves.decelerate,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      forwardAnimationCurve: Curves.ease,
                      maxWidth: MediaQuery.of(context).size.width * .3,
                      backgroundColor: Colors.red,
                      isDismissible: true,
                      duration: Duration(seconds: 2),
                    ).show(context);
                  } else if (state is SuccessCubitState) {
                    for (var jogador in _cubitJogadores.jogadoresList) {
                      final jogadorId = jogador.id;
                      if (_cubitEditarTreino.presentes.contains(jogadorId)) {
                        _cubitEditarPresenca.editarPresenca(tipo: "presencas", jogadorId: jogadorId);
                      } else {
                        _cubitEditarPresenca.editarPresenca(tipo: "faltas", jogadorId: jogadorId);
                      }
                    }
                  }
                }),
            BlocListener(
                bloc: _cubitTreinoById,
                listener: (context, state) async {
                  if (loading) {
                    Modular.to.pop();
                    loading = false;
                  }
                  if (state is LoadingCubitState) {
                    setState(() {
                      loading = true;
                    });
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return LoaderWidget();
                      },
                    );
                  } else if (state is ErrorCubitState) {
                    if (loading) {
                      Modular.to.pop();
                      loading = false;
                    }
                    await Flushbar(
                      margin: EdgeInsets.all(8),
                      message: state.message,
                      titleColor: Colors.white,
                      flushbarPosition: FlushbarPosition.TOP,
                      flushbarStyle: FlushbarStyle.FLOATING,
                      reverseAnimationCurve: Curves.decelerate,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      forwardAnimationCurve: Curves.ease,
                      maxWidth: MediaQuery.of(context).size.width * .3,
                      backgroundColor: Colors.red,
                      isDismissible: true,
                      duration: Duration(seconds: 2),
                    ).show(context);
                  } else if (state is SuccessCubitState) {
                    if (loading) {
                      Modular.to.pop();
                      loading = false;
                    }

                    final TreinosEntity treinoData = state.value;
                    DateFormat dateFormat = DateFormat("dd/MM/yyyy");
                    _descricaoController.text = treinoData.descricao;
                    _cubitEditarTreino.onSaveDescricao(treinoData.descricao);
                    _cubitEditarTreino.onSaveData(treinoData.data);

                    _selectedDate = dateFormat.parse(treinoData.data); // Data do treino

                    setState(() => _cubitEditarTreino.onSavePresentes(treinoData.presenca));
                  }
                }),
            BlocListener(
                bloc: _cubitJogadores,
                listener: (context, state) async {
                  if (loading) {
                    Modular.to.pop();
                    loading = false;
                  }
                  if (state is LoadingCubitState) {
                    setState(() {
                      loading = true;
                    });
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return LoaderWidget();
                      },
                    );
                  } else if (state is ErrorCubitState) {
                    if (loading) {
                      Modular.to.pop();
                      loading = false;
                    }
                    await Flushbar(
                      margin: EdgeInsets.all(8),
                      message: state.message,
                      titleColor: Colors.white,
                      flushbarPosition: FlushbarPosition.TOP,
                      flushbarStyle: FlushbarStyle.FLOATING,
                      reverseAnimationCurve: Curves.decelerate,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      forwardAnimationCurve: Curves.ease,
                      maxWidth: MediaQuery.of(context).size.width * .3,
                      backgroundColor: Colors.red,
                      isDismissible: true,
                      duration: Duration(seconds: 2),
                    ).show(context);
                  }
                })
          ],
          child: _cubitJogadores.jogadoresList.isEmpty
              ? Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Campo para descrição
                          TextFormField(
                            controller: _descricaoController,
                            decoration: InputDecoration(
                              labelText: "Descrição",
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) => _cubitEditarTreino.onSaveDescricao(value),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira a descrição';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),

                          // Date Picker
                          Text(
                            "Data do Treino",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xff018055),
                            ),
                          ),
                          SizedBox(height: 8),
                          CustomDatePickerPopup(
                            onDateSelected: (DateTime date) {
                              setState(() {
                                _cubitEditarTreino.onSaveData(date.toIso8601String());
                              });
                            },
                          ),
                          SizedBox(height: 16),

                          // Lista de jogadores
                          Text(
                            "Jogadores Presentes",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xff018055),
                            ),
                          ),
                          SizedBox(height: 8),
                          Column(
                            children: _cubitJogadores.jogadoresList.map((jogador) {
                              final isSelected = _cubitEditarTreino.presentes.contains(jogador.id);
                              return CheckboxListTile(
                                title: Text(jogador.nome),
                                value: isSelected,
                                activeColor: Color(0xff018055),
                                onChanged: (bool? selected) {
                                  setState(() {
                                    if (selected == true) {
                                      _cubitEditarTreino.presentes.add(jogador.id);
                                    } else {
                                      _cubitEditarTreino.presentes.remove(jogador.id);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 24),

                          // Botão de salvar
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _cubitEditarTreino.editarTreino(widget.treinoId);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff018055),
                              ),
                              child: Text(
                                "Salvar",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ));
  }
}
