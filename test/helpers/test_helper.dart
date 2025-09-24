import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Mock Firebase App para testes
class MockFirebaseApp extends Fake implements FirebaseApp {
  @override
  String get name => '[DEFAULT]';
}

/// Helper para configurar ambiente de teste sem Firebase
class TestHelper {
  static Future<void> setupTestEnvironment() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Desabilita Crashlytics durante os testes
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  }
}