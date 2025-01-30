import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:fominhas/core/state/cubit_state.dart';
import 'package:fominhas/features/login/presentation/cubit/login_google_cubit.dart';
import 'package:fominhas/features/login/presentation/cubit/login_apple_cubit.dart';
import 'package:fominhas/features/widgets/loader/loader_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _cubitLoginGoogle = Modular.get<LoginGoogleCubit>();
  final _cubitLoginApple = Modular.get<LoginAppleCubit>(); // Novo Cubit
  bool loading = false;

  void _handleAuthState(dynamic state) async {
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
        duration: Duration(seconds: 4),
      ).show(context);
    } else if (state is SuccessCubitState) {
      Modular.to.pushNamed("/home/");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff018055), Color(0xff018055)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              CircleAvatar(
                radius: 62,
                child: SvgPicture.asset(
                  "assets/images/fominhas_logo.svg",
                  colorFilter: ColorFilter.mode(Color(0xff018055), BlendMode.srcATop),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Bem-vindo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),

              // Botão de login com Google
              BlocConsumer(
                bloc: _cubitLoginGoogle,
                listener: (context, state) => _handleAuthState(state),
                builder: (context, state) {
                  return ElevatedButton.icon(
                    onPressed: () => _cubitLoginGoogle.loginGoogle(),
                    icon: Icon(Icons.trolley),
                    label: Text(
                      'Continuar com Google',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              // Botão de login com Apple
              BlocConsumer(
                bloc: _cubitLoginApple,
                listener: (context, state) => _handleAuthState(state),
                builder: (context, state) {
                  return SignInWithAppleButton(
                    onPressed: () => _cubitLoginApple.loginApple(),
                    style: SignInWithAppleButtonStyle.white,
                  );
                },
              ),

              const SizedBox(height: 20),

              // Mensagem informativa
              Text(
                'Faça login para continuar',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
