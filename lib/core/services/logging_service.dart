import 'dart:developer' as developer;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Serviço de logging estruturado que integra com Firebase Crashlytics
/// Garante que todos os logs incluam timestamp conforme requerido pelo usuário
class LoggingService {
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  static const String _appName = 'Fominhas';

  /// Inicializa o serviço de logging
  static Future<void> initialize() async {
    try {
      // Configura para capturar erros automáticos
      await _crashlytics.setCrashlyticsCollectionEnabled(true);
      
      // Log de inicialização
      info('LoggingService inicializado com sucesso');
    } catch (e) {
      developer.log(
        'Erro ao inicializar LoggingService: $e',
        time: DateTime.now(),
        name: _appName,
        level: 1000, // Error level
      );
    }
  }

  /// Log de informação com timestamp obrigatório
  static void info(String message, {Map<String, dynamic>? data}) {
    final timestamp = DateTime.now().toIso8601String();
    final structuredMessage = '[$timestamp] INFO: $message';
    
    developer.log(
      structuredMessage,
      time: DateTime.now(),
      name: _appName,
      level: 800, // Info level
    );

    if (data != null) {
      _crashlytics.setCustomKey('last_info_data', data.toString());
    }
  }

  /// Log de warning com timestamp obrigatório
  static void warning(String message, {Map<String, dynamic>? data}) {
    final timestamp = DateTime.now().toIso8601String();
    final structuredMessage = '[$timestamp] WARNING: $message';
    
    developer.log(
      structuredMessage,
      time: DateTime.now(),
      name: _appName,
      level: 900, // Warning level
    );

    _crashlytics.log(structuredMessage);
    
    if (data != null) {
      _crashlytics.setCustomKey('last_warning_data', data.toString());
    }
  }

  /// Log de erro com timestamp obrigatório e envio para Crashlytics
  static void error(
    String message, {
    Object? exception,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final structuredMessage = '[$timestamp] ERROR: $message';
    
    developer.log(
      structuredMessage,
      time: DateTime.now(),
      name: _appName,
      level: 1000, // Error level
      error: exception,
      stackTrace: stackTrace,
    );

    // Enviar para Crashlytics
    _crashlytics.log(structuredMessage);
    
    if (data != null) {
      _crashlytics.setCustomKey('error_context', data.toString());
    }

    if (exception != null) {
      _crashlytics.recordError(
        exception,
        stackTrace,
        information: [
          DiagnosticsProperty('message', message),
          if (data != null) DiagnosticsProperty('data', data),
        ],
      );
    }
  }

  /// Log de debug com timestamp obrigatório (apenas em modo debug)
  static void debug(String message, {Map<String, dynamic>? data}) {
    final timestamp = DateTime.now().toIso8601String();
    final structuredMessage = '[$timestamp] DEBUG: $message';
    
    developer.log(
      structuredMessage,
      time: DateTime.now(),
      name: _appName,
      level: 700, // Debug level
    );

    // Debug logs não são enviados para produção
    if (data != null) {
      developer.log(
        'Debug data: ${data.toString()}',
        time: DateTime.now(),
        name: _appName,
        level: 700,
      );
    }
  }

  /// Define o ID do usuário para contexto nos logs
  static Future<void> setUserId(String userId) async {
    await _crashlytics.setUserIdentifier(userId);
    info('User ID definido para logging', data: {'userId': userId});
  }

  /// Define dados customizados do usuário
  static Future<void> setUserData({
    String? email,
    String? name,
    Map<String, dynamic>? customData,
  }) async {
    if (email != null) {
      await _crashlytics.setCustomKey('user_email', email);
    }
    if (name != null) {
      await _crashlytics.setCustomKey('user_name', name);
    }
    if (customData != null) {
      for (final entry in customData.entries) {
        await _crashlytics.setCustomKey(entry.key, entry.value.toString());
      }
    }
    
    info('Dados do usuário atualizados para logging');
  }

  /// Log específico para dados estruturados do app
  /// Garante que dados sejam estruturados como {"json": bodyData} para Elastic
  static void logStructuredData(
    String event,
    Map<String, dynamic> bodyData, {
    String level = 'info',
  }) {
    final timestamp = DateTime.now().toIso8601String();
    
    // Estrutura obrigatória para Elastic conforme regra do usuário
    final structuredData = {
      'timestamp': timestamp,
      'event': event,
      'json': bodyData, // Formato exigido pelo Elastic
    };

    final message = '[$timestamp] STRUCTURED_EVENT: $event';
    
    switch (level.toLowerCase()) {
      case 'error':
        error(message, data: structuredData);
        break;
      case 'warning':
        warning(message, data: structuredData);
        break;
      case 'debug':
        debug(message, data: structuredData);
        break;
      default:
        info(message, data: structuredData);
    }

    // Enviar dados estruturados para Crashlytics
    _crashlytics.setCustomKey('last_structured_event', event);
    _crashlytics.setCustomKey('last_structured_data', structuredData.toString());
  }

  /// Log de eventos de torneio com dados estruturados
  static void logTournamentEvent(
    String tournamentId,
    String eventType,
    Map<String, dynamic> eventData,
  ) {
    final bodyData = {
      'tournament_id': tournamentId,
      'event_type': eventType,
      'data': eventData,
    };

    logStructuredData('tournament_event', bodyData);
  }

  /// Log de eventos de partida com dados estruturados
  static void logMatchEvent(
    String matchId,
    String eventType,
    Map<String, dynamic> eventData,
  ) {
    final bodyData = {
      'match_id': matchId,
      'event_type': eventType,
      'data': eventData,
    };

    logStructuredData('match_event', bodyData);
  }

  /// Log de erros críticos que devem ser reportados imediatamente
  static void logCriticalError(
    String message,
    Object exception, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    
    // Log crítico sempre com máxima prioridade
    error(
      'CRITICAL: $message',
      exception: exception,
      stackTrace: stackTrace,
      data: {
        'timestamp': timestamp,
        'is_critical': true,
        if (context != null) 'context': context,
      },
    );

    // Forçar envio imediato para Crashlytics
    _crashlytics.sendUnsentReports();
  }

  /// Limpa dados customizados (útil para logout)
  static Future<void> clearUserData() async {
    await _crashlytics.deleteUnsentReports();
    await _crashlytics.setUserIdentifier('');
    info('Dados do usuário limpos do logging');
  }
}

/// Classe de propriedade de diagnóstico para Crashlytics
class DiagnosticsProperty {
  final String name;
  final dynamic value;
  
  const DiagnosticsProperty(this.name, this.value);
  
  @override
  String toString() => '$name: $value';
}