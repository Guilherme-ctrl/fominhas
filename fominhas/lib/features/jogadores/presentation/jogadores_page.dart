import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:fominhas/core/cubit/get_jogadores_cubit.dart';
import 'package:fominhas/core/domain/entities/jogadores/jogadores_response_entity.dart';

import '../../../core/state/cubit_state.dart';
import '../../widgets/loader/loader_widget.dart';

class JogadoresPage extends StatefulWidget {
  const JogadoresPage({super.key});

  @override
  State<JogadoresPage> createState() => _JogadoresPageState();
}

class _JogadoresPageState extends State<JogadoresPage> {
  final _cubitJogadores = Modular.get<GetJogadoresCubit>();
  final TextEditingController _searchController = TextEditingController();
  List<JogadoresResponseEntity> _jogadoresFiltrados = [];
  List<JogadoresResponseEntity> _todosJogadores = [];
  bool loading = false;

  @override
  void initState() {
    _cubitJogadores.getJogadores();
    super.initState();
  }

  void _filtrarJogadores(String query) {
    setState(() {
      if (query.isEmpty) {
        _jogadoresFiltrados = _todosJogadores;
      } else {
        _jogadoresFiltrados = _todosJogadores.where((jogador) => jogador.nome.toLowerCase().contains(query.toLowerCase())).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lista de Atletas',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 10),

            // Barra de busca
            TextField(
              controller: _searchController,
              onChanged: _filtrarJogadores,
              decoration: InputDecoration(
                hintText: 'Buscar atleta pelo nome...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: Color(0xff018055)),
              ),
            ),
            SizedBox(height: 16),

            BlocConsumer<GetJogadoresCubit, CubitState>(
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
                } else if (state is SuccessCubitState) {
                  setState(() {
                    _todosJogadores = state.value;
                    _jogadoresFiltrados = _todosJogadores;
                  });
                }
              },
              builder: (context, state) {
                if (state is SuccessCubitState) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: _jogadoresFiltrados.length,
                      itemBuilder: (context, index) {
                        _jogadoresFiltrados.sort((a, b) => b.faltas.compareTo(a.faltas));
                        var item = _jogadoresFiltrados[index];

                        return InkWell(
                          onTap: () => Modular.to.pushNamed("/home/editar_jogador/", arguments: item.id),
                          child: Card(
                            elevation: 3,
                            margin: EdgeInsets.symmetric(vertical: 8),
                            color: Colors.white,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(item.nome),
                              subtitle: Row(
                                children: [
                                  Text("Número: ${item.numero.toString()}"),
                                  SizedBox(width: 8),
                                  Text("Faltas: ${item.faltas.toString()}"),
                                ],
                              ),
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
                onPressed: () {
                  Modular.to.pushNamed("/home/adicionar_jogador/");
                },
                backgroundColor: Color(0xff018055),
                label: Text(
                  'Adicionar Atleta',
                  style: TextStyle(color: Colors.white),
                ),
                icon: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
