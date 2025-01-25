import 'package:flutter_modular/flutter_modular.dart';
import 'package:fominhas/features/app/module/app_module.dart';
import 'package:fominhas/features/login/presentation/login_page.dart';

class LoginModule extends Module {
  @override
  List<Module> get imports => [AppModule()];

  @override
  void binds(i) {}

  @override
  void routes(r) {
    r.child(Modular.initialRoute, child: (context) => LoginPage());
  }
}
