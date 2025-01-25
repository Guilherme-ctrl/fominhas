import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:fominhas/core/cubit/user_cubit.dart';
import 'package:fominhas/core/state/cubit_state.dart';
import 'package:fominhas/features/treinos/domain/entities/treinos_entity.dart';
import 'package:fominhas/features/treinos/presentation/cubit/treinos_cubit.dart';
import '../../widgets/loader/loader_widget.dart';

class TreinosPage extends StatefulWidget {
  const TreinosPage({super.key});

  @override
  State<TreinosPage> createState() => _TreinosPageState();
}

class _TreinosPageState extends State<TreinosPage> {
  final _cubitUser = Modular.get<UserCubit>();
  final _cubitTreinos = Modular.get<TreinosCubit>();
  bool loading = false;
  @override
  void initState() {
    _cubitUser.getUser();
    _cubitTreinos.getTreinos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder(
            bloc: _cubitUser,
            builder: (context, state) {
              if (state is SuccessCubitState) {
                final User user = state.value;
                return Text(
                  'Bem vindo ${user.displayName}',
                  style: Theme.of(context).textTheme.headlineSmall,
                );
              } else {
                return Text(
                  'Bem vindo',
                  style: Theme.of(context).textTheme.headlineSmall,
                );
              }
            },
          ),
          SizedBox(height: 10),
          BlocConsumer(
            bloc: _cubitTreinos,
            listener: (context, state) async {
              if (loading) {
                Modular.to.pop();
                loading = false;
              }
              if (state is LoadingCubitState) {
                setState(() {
                  loading = true;
                });
                //_showLoadingPopup(context);
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
            },
            builder: (context, state) {
              if (state is SuccessCubitState) {
                final List<TreinosEntity> treinos = state.value;
                treinos.sort((a, b) => b.data.compareTo(a.data));
                return Expanded(
                  child: ListView.builder(
                    itemCount: treinos.length,
                    itemBuilder: (context, index) {
                      final item = treinos[index];
                      return InkWell(
                        onTap: () {
                          Modular.to.pushNamed("/home/editar_treinos/", arguments: item.id);
                        },
                        child: Card(
                          elevation: 3,
                          color: Colors.white,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(item.data),
                            subtitle: Text(item.descricao),
                            trailing: Icon(Icons.arrow_forward_ios, size: 18),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FloatingActionButton.extended(
              onPressed: () => Modular.to.pushNamed("/home/adicionar_treinos/"),
              label: Text(
                'Adicionar Treino',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Color(0xff018055),
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
