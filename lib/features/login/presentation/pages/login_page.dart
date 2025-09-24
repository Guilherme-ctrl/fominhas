import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fominhas/core/state/cubit_state.dart';
import 'package:fominhas/core/extensions/cubit_state_extensions.dart';
import 'package:fominhas/core/theme/app_theme.dart';
import 'package:fominhas/features/widgets/loader/loader_widget.dart';
import '../cubit/login_google_cubit.dart';
import '../cubit/login_apple_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.7, 1.0],
            colors: [
              AppTheme.backgroundDark,
              AppTheme.surfaceDark,
              AppTheme.cardDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const Spacer(),
                
                // Logo e branding
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withValues(alpha: 0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: SvgPicture.asset(
                          'assets/images/fominhas_logo.svg',
                          width: 50,
                          height: 50,
                          colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Título principal
                      Text(
                        'Fominhas',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Subtítulo
                      Text(
                        'Gerenciamento de Futebol Indoor',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),

                // Botões de login
                Column(
                  children: [
                    // Botão Google
                    BlocConsumer(
                      bloc: Modular.get<LoginGoogleCubit>(),
                      listener: (context, state) {
                        if (state is LoadingCubitState) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return LoaderWidget();
                            },
                          );
                        }
                        if (state is SuccessCubitState) {
                          Modular.to.pop();
                          Modular.to.navigate('/home/');
                        }

                        if (state is ErrorCubitState) {
                          log(state.message);
                          Modular.to.pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              backgroundColor: AppTheme.errorColor,
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        return Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.grey.shade50,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: state is LoadingCubitState
                                ? null
                                : () => Modular.get<LoginGoogleCubit>().signInWithGoogle(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.black87,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (state is LoadingCubitState)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(Colors.black54),
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Image.asset(
                                      'assets/images/google_logo.png',
                                      width: 18,
                                      height: 18,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.login,
                                          size: 20,
                                          color: Colors.black54,
                                        );
                                      },
                                    ),
                                  ),
                                const SizedBox(width: 12),
                                Text(
                                  'Entrar com Google',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Botão Apple
                    BlocConsumer<LoginAppleCubit, CubitState>(
                      bloc: Modular.get<LoginAppleCubit>(),
                      listener: (context, state) {
                        state.whenSuccess((user) {
                          Modular.to.navigate('/home/');
                        });
                        
                        state.whenError((message) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                              backgroundColor: AppTheme.errorColor,
                            ),
                          );
                        });
                      },
                      builder: (context, state) {
                        return Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Colors.black,
                                Color(0xFF1C1C1E),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: state.isLoading
                                ? null
                                : () => Modular.get<LoginAppleCubit>().signInWithApple(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (state.isLoading)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(Colors.white70),
                                    ),
                                  )
                                else
                                  const Icon(
                                    Icons.apple,
                                    size: 22,
                                    color: Colors.white,
                                  ),
                                const SizedBox(width: 12),
                                Text(
                                  'Entrar com Apple',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // Footer
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      Text(
                        'Ao continuar, você concorda com nossos',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Termos de Uso',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.primaryColor,
                                decoration: TextDecoration.underline,
                                decorationColor: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          Text(
                            ' e ',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textTertiary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Política de Privacidade',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.primaryColor,
                                decoration: TextDecoration.underline,
                                decorationColor: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
