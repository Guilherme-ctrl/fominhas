import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:fominhas/core/domain/entities/jogadores/jogadores_response_entity.dart';
import 'package:fominhas/features/jogadores/presentation/cubit/editar_jogador_cubit.dart';
import 'package:fominhas/features/jogadores/presentation/cubit/jogador_by_id_cubit.dart';

import '../../../core/state/cubit_state.dart';
import '../../widgets/loader/loader_widget.dart';

class EditarJogadorPage extends StatefulWidget {
  final String jogadorId;

  const EditarJogadorPage({super.key, required this.jogadorId});

  @override
  _EditarJogadorPageState createState() => _EditarJogadorPageState();
}

class _EditarJogadorPageState extends State<EditarJogadorPage> {
  final _formKey = GlobalKey<FormState>();
  final _cubitJogadorById = Modular.get<JogadorByIdCubit>();
  final _cubitEditarJogador = Modular.get<EditarJogadorCubit>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _documentoController = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _cubitJogadorById.jogadorById(widget.jogadorId);
  }

  Future<void> _salvarJogador() async {
    if (_formKey.currentState!.validate()) {
      // Verifica quais campos foram alterados
      if (_nomeController.text != _cubitEditarJogador.dadosOriginais!.nome) {
        _cubitEditarJogador.onSaveNome(_nomeController.text);
      }
      if (_numeroController.text != (_cubitEditarJogador.dadosOriginais!.numero.toString())) {
        _cubitEditarJogador.onSaveNumero(_numeroController.text);
      }
      if (_emailController.text != _cubitEditarJogador.dadosOriginais!.email) {
        _cubitEditarJogador.onSaveEmail(_emailController.text);
      }
      if (_documentoController.text != _cubitEditarJogador.dadosOriginais!.documento) {
        _cubitEditarJogador.onSaveDocumento(_documentoController.text);
      }

      _cubitEditarJogador.editarJogador(widget.jogadorId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Editar Jogador",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xff018055),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener(
                bloc: _cubitEditarJogador,
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
                      message: "Atualizado com sucesso!",
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
                    ).show(context).then((_) => Modular.to.popAndPushNamed("/home/"));
                  }
                }),
            BlocListener(
                bloc: _cubitJogadorById,
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

                    JogadoresResponseEntity jogadorDoc = state.value;

                    setState(() {
                      _cubitEditarJogador.onSaveDadosOriginais(jogadorDoc);
                      _cubitEditarJogador.onSaveNome(jogadorDoc.nome);
                      _cubitEditarJogador.onSaveNumero(jogadorDoc.numero.toString());
                      _cubitEditarJogador.onSaveEmail(jogadorDoc.email);
                      _cubitEditarJogador.onSaveDocumento(jogadorDoc.documento);
                      _nomeController.text = jogadorDoc.nome;
                      _numeroController.text = jogadorDoc.numero.toString();
                      _emailController.text = jogadorDoc.email;
                      _documentoController.text = jogadorDoc.documento;
                    });
                  }
                })
          ],
          child: Container(
            color: Color(0xffF7F7F7),
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Campo Nome
                    Text(
                      "Nome do Jogador",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff018055),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _nomeController,
                      decoration: InputDecoration(
                        hintText: "Ex: João Silva",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o nome do jogador';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Campo Número da Camisa
                    Text(
                      "Número da Camisa",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff018055),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _numeroController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Ex: 10",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o número da camisa';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Por favor, insira um número válido';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Campo Email
                    Text(
                      "Email do Jogador",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff018055),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Ex: joao@email.com",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o email';
                        }
                        if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
                          return 'Por favor, insira um email válido';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Campo Documento
                    Text(
                      "Documento do Jogador",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff018055),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _documentoController,
                      decoration: InputDecoration(
                        hintText: "Ex: 123456789",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o documento';
                        }
                        if (value.length < 8) {
                          return 'O documento deve ter pelo menos 8 caracteres';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),

                    // Botão de Salvar
                    Center(
                      child: ElevatedButton(
                        onPressed: _salvarJogador,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff018055),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 24,
                          ),
                        ),
                        child: Text(
                          "Salvar Alterações",
                          style: TextStyle(fontSize: 16, color: Colors.white),
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
