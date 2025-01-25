import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:fominhas/features/jogadores/presentation/cubit/adicionar_jogadores_cubit.dart';
import '../../../core/state/cubit_state.dart';
import '../../widgets/loader/loader_widget.dart';

class AdicionarJogadorPage extends StatefulWidget {
  const AdicionarJogadorPage({super.key});

  @override
  _AdicionarJogadorPageState createState() => _AdicionarJogadorPageState();
}

class _AdicionarJogadorPageState extends State<AdicionarJogadorPage> {
  final _cubitAdicionarJogadores = Modular.get<AdicionarJogadoresCubit>();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Adicionar Jogador"),
        backgroundColor: Color(0xff018055),
      ),
      body: Container(
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
                  onChanged: (value) => _cubitAdicionarJogadores.onSaveNome(value),
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
                  onChanged: (value) => _cubitAdicionarJogadores.onSaveNumero(value),
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
                  onChanged: (value) => _cubitAdicionarJogadores.onSaveEmail(value),
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
                  onChanged: (value) => _cubitAdicionarJogadores.onSaveDocumento(value),
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
                  child: BlocConsumer(
                    bloc: _cubitAdicionarJogadores,
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
                          message: "Treino registrado com sucesso!",
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
                          Modular.to.popAndPushNamed("/home/");
                        });
                      }
                    },
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _cubitAdicionarJogadores.adicionarJogador();
                          }
                        },
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
                          "Salvar Jogador",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
