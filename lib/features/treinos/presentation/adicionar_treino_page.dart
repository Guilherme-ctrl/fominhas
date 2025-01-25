import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:fominhas/core/state/cubit_state.dart';
import 'package:fominhas/features/treinos/presentation/cubit/adicionar_treino_cubit.dart';

import '../../widgets/date_picker/custom_date_picker.dart';
import '../../widgets/loader/loader_widget.dart';

class AdicionarTreinoPage extends StatefulWidget {
  const AdicionarTreinoPage({super.key});

  @override
  _AdicionarTreinoPageState createState() => _AdicionarTreinoPageState();
}

class _AdicionarTreinoPageState extends State<AdicionarTreinoPage> {
  final _formKey = GlobalKey<FormState>();
  final _cubitAdicionarTreino = Modular.get<AdicionarTreinoCubit>();
  bool loading = false;
  bool loading1 = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Adicionar Treino',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xff018055),
        elevation: 0,
      ),
      body: Container(
        color: Color(0xffF7F7F7),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Campo para descrição
                Text(
                  "Descrição do Treino",
                  style: TextStyle(
                    color: Color(0xff018055),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  onChanged: (value) {
                    _cubitAdicionarTreino.onSaveDescricao(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Ex: Finalizações e posse de bola',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a descrição';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Campo para data
                Text(
                  "Data do Treino",
                  style: TextStyle(
                    color: Color(0xff018055),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                CustomDatePickerPopup(onDateSelected: (DateTime data) {
                  _cubitAdicionarTreino.onSaveData(data.toIso8601String());
                }),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: BlocConsumer(
        bloc: _cubitAdicionarTreino,
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
          return Align(
            alignment: Alignment.bottomCenter,
            child: FloatingActionButton.extended(
              onPressed: () => _cubitAdicionarTreino.adicionarTreino(),
              backgroundColor: Color(0xff018055),
              icon: Icon(
                Icons.save,
                color: Colors.white,
              ),
              label: Text(
                "Salvar",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}
