import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:fominhas/features/app/module/app_module.dart';
import 'package:fominhas/features/app/presentation/app_widget.dart';
import 'package:fominhas/core/services/logging_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Inicializar Firebase
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    
    // Configurar Crashlytics explicitamente
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    
    // Configurar captura de erros do Flutter
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    
    // Capturar erros assíncronos não tratados
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    
    // Inicializar serviço de logging estruturado
    await LoggingService.initialize();
    
    // Log de inicialização da aplicação
    LoggingService.info('Aplicação Fominhas iniciada com Firebase configurado');
    
  } catch (e, stackTrace) {
    // Fallback caso falhe a inicialização do Firebase
    // Usar debugPrint para desenvolvimento e tentar logging estruturado
    debugPrint('🔥 CRÍTICO: Erro ao inicializar Firebase: $e');
    debugPrint('StackTrace: $stackTrace');
    
    // Tentar registrar erro diretamente no Crashlytics se disponível
    try {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        fatal: true,
        information: [
          'Erro crítico na inicialização do Firebase',
          'Contexto: main() startup',
          'Impacto: App pode não funcionar corretamente',
        ],
      );
    } catch (crashlyticsError) {
      debugPrint('Crashlytics também falhou: $crashlyticsError');
    }
    
    // Ainda assim inicializar o serviço de logging
    try {
      await LoggingService.initialize();
      LoggingService.error(
        'Erro na inicialização do Firebase', 
        exception: e, 
        stackTrace: stackTrace,
        data: {
          'startup_phase': 'firebase_initialization',
          'critical_error': true,
        },
      );
    } catch (loggingError) {
      // Último recurso: usar debugPrint em vez de print
      debugPrint('🚨 FALHA TOTAL: Erro ao inicializar logging: $loggingError');
      
      // Tentar Crashlytics novamente para este erro também
      try {
        FirebaseCrashlytics.instance.recordError(
          loggingError,
          StackTrace.current,
          fatal: false,
          information: [
            'Falha ao inicializar LoggingService após erro do Firebase',
            'Erro original Firebase: ${e.toString()}',
          ],
        );
      } catch (_) {
        // Se chegou até aqui, algo está muito errado
        debugPrint('💥 Sistema de logging completamente inoperante');
      }
    }
  }

  runApp(ModularApp(module: AppModule(), child: AppWidget()));
}
