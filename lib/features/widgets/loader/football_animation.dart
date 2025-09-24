import 'package:flutter/cupertino.dart';

class AnimatedFootball extends StatefulWidget {
  const AnimatedFootball({super.key});

  @override
  State<AnimatedFootball> createState() => _AnimatedFootballState();
}

class _AnimatedFootballState extends State<AnimatedFootball> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * 3.14159265359,
            child: child,
          );
        },
        child: Image.asset(
          'assets/images/football.png', // Adicione uma imagem de bola de futebol ao diretório assets
          width: 60,
          height: 60,
        ),
      ),
    );
  }
}
