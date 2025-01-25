import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

import '../../../features/widgets/loader/loader_widget.dart';
import '../../state/cubit_state.dart';

class Listeners {
  listenerDefault(
      {required BuildContext context,
      required Object state,
      required Function() onLoading,
      required Function() onError,
      required Function() onSuccess,
      required Function() onDefault}) async {
    onDefault;
    if (state is LoadingCubitState) {
      onLoading;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return LoaderWidget();
        },
      );
    } else if (state is ErrorCubitState) {
      onError;
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
      onSuccess;
    }
  }
}
