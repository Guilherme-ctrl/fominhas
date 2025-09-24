import 'package:mocktail/mocktail.dart';

class MockLoggingService extends Mock {
  static void mockAllMethods() {
    // Mocka todos os métodos estáticos do LoggingService
    // para que não tentem acessar Firebase durante os testes
  }

  // Métodos mock que não fazem nada
  static void info(String message, {Map<String, dynamic>? data}) {
    // Mock - não faz nada
  }

  static void warning(String message, {Map<String, dynamic>? data}) {
    // Mock - não faz nada
  }

  static void error(String message, {Object? exception, StackTrace? stackTrace, Map<String, dynamic>? data}) {
    // Mock - não faz nada
  }

  static void debug(String message, {Map<String, dynamic>? data}) {
    // Mock - não faz nada
  }

  static void logStructuredData(String event, Map<String, dynamic> bodyData, {String level = 'info'}) {
    // Mock - não faz nada
  }

  static void logTournamentEvent(String tournamentId, String eventType, Map<String, dynamic> eventData) {
    // Mock - não faz nada
  }

  static void logMatchEvent(String matchId, String eventType, Map<String, dynamic> eventData) {
    // Mock - não faz nada
  }

  static Future<void> setUserId(String userId) async {
    // Mock - não faz nada
  }

  static Future<void> setUserData({String? email, String? name, Map<String, dynamic>? customData}) async {
    // Mock - não faz nada
  }
}
