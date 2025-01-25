import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fominhas/features/jogadores/presentation/jogadores_page.dart';
import 'package:fominhas/features/treinos/presentation/treinos_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

class NavegationController extends StatefulWidget {
  const NavegationController({super.key});

  @override
  State<NavegationController> createState() => _NavegationControllerState();
}

class _NavegationControllerState extends State<NavegationController> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    TreinosPage(),
    JogadoresPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        toolbarHeight: 80,
        leading: SizedBox(),
        title: SizedBox(width: 64, height: 64, child: SvgPicture.asset("assets/images/fominhas_logo.svg")),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
              onPressed: () async {
                final GoogleSignIn googleSignIn = GoogleSignIn();
                await googleSignIn.signOut();
                await FirebaseAuth.instance.signOut().then((_) {
                  Modular.to.pushNamedAndRemoveUntil(Modular.initialRoute, (_) => false);
                });
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: SizedBox(
        height: 120,
        child: BottomNavigationBar(
          backgroundColor: Color(0xff018055),
          selectedItemColor: Colors.white,
          onTap: _onItemTapped,
          currentIndex: _selectedIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_outlined),
              label: 'Treinos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Atletas',
            ),
          ],
        ),
      ),
    );
  }
}
