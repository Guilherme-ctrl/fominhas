import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../../core/cubit/user_cubit.dart';
import '../../../players/presentation/pages/players_page.dart';
import '../../../tournament/presentation/pages/tournaments_management_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, dynamic>(
      bloc: Modular.get<UserCubit>(),
      builder: (context, user) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Fominhas'),
            actions: [
              PopupMenuButton(
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        child: ListTile(
                          leading: const Icon(Icons.logout),
                          title: const Text('Sair'),
                          onTap: () async {
                            Modular.to.pop();
                            // Clear user and navigate to login
                            Modular.get<UserCubit>().clearUser();
                            Modular.to.navigate('/');
                          },
                        ),
                      ),
                    ],
              ),
            ],
          ),
          body: IndexedStack(index: _selectedIndex, children: [_buildPlayersTab(), _buildTournamentsTab()]),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Jogadores'),
              BottomNavigationBarItem(icon: Icon(Icons.sports_soccer), label: 'Torneios'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayersTab() {
    return const PlayersPage();
  }

  Widget _buildTournamentsTab() {
    return const TournamentsManagementPage();
  }
}
