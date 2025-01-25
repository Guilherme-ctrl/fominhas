import 'package:flutter/material.dart';
import 'package:fominhas/features/widgets/loader/football_animation.dart';

class LoaderWidget extends StatelessWidget {
  const LoaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      content: Center(
        child: Container(
          width: 120,
          height: 120,
          color: Colors.transparent,
          child: AnimatedFootball(),
        ),
      ),
    );
  }
}
