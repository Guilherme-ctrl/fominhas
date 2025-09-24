import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class PhotoService {
  static final ImagePicker _imagePicker = ImagePicker();

  /// Verifica e solicita permissões da câmera
  static Future<bool> requestCameraPermission() async {
    try {
      // Verificar status atual da permissão
      PermissionStatus status = await Permission.camera.status;
      
      
      // Se já concedido, retornar true
      if (status == PermissionStatus.granted) {
        return true;
      }
      
      // Se negado permanentemente, não podemos fazer nada
      if (status == PermissionStatus.permanentlyDenied) {
        return false;
      }
      
      // Solicitar permissão
      status = await Permission.camera.request();
      
      return status == PermissionStatus.granted;
      
    } catch (e) {
      return false;
    }
  }

  /// Captura uma foto usando a câmera
  static Future<File?> takePhoto() async {
    try {
      
      // Verificar permissão da câmera
      final hasPermission = await requestCameraPermission();
      if (!hasPermission) {
        
        final status = await Permission.camera.status;
        if (status == PermissionStatus.permanentlyDenied) {
          throw Exception('Permissão da câmera foi negada permanentemente.\n\nPor favor, vá nas Configurações do app e habilite o acesso à câmera para capturar fotos dos campeões.');
        } else {
          throw Exception('Permissão da câmera é necessária para capturar fotos dos times campeões.');
        }
      }

      // Capturar foto
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85, // Reduz um pouco a qualidade para economizar espaço
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (photo == null) {
        return null;
      }

      final File photoFile = File(photo.path);
      
      return photoFile;
    } catch (e) {
      throw Exception('Erro ao capturar foto: $e');
    }
  }

  /// Converte uma foto para base64
  static Future<String> convertPhotoToBase64(File photoFile) async {
    try {
      
      // Verificar se o arquivo existe
      if (!await photoFile.exists()) {
        throw Exception('Arquivo de foto não encontrado: ${photoFile.path}');
      }
      
      // File validation - size could be checked here if needed
      
      // Ler os bytes do arquivo
      final Uint8List photoBytes = await photoFile.readAsBytes();
      
      // Converter para base64
      final String base64String = base64Encode(photoBytes);
      
      return base64String;
      
    } catch (e) {
      throw Exception('Erro ao processar a foto: $e');
    }
  }

  /// Como agora usamos base64, não precisamos deletar arquivos separadamente
  /// A foto é removida quando o campo winnerPhotoBase64 é removido do documento

  /// Captura e converte a foto do time vencedor para base64
  static Future<String?> captureWinnerPhotoAsBase64() async {
    try {
      
      // Capturar foto
      final File? photoFile = await takePhoto();
      if (photoFile == null) {
        return null;
      }

      // Converter para base64
      final String base64Photo = await convertPhotoToBase64(photoFile);
      
      // Limpar arquivo temporário
      try {
        await photoFile.delete();
      } catch (e) {
        // Log erro de limpeza de arquivo temporário para monitoramento
        FirebaseCrashlytics.instance.recordError(
          e,
          StackTrace.current,
          fatal: false,
          information: [
            'Erro ao deletar arquivo temporário de foto',
            'Caminho do arquivo: ${photoFile.path}',
            'Operação: captureWinnerPhotoAsBase64',
          ],
        );
        // Não rethrow pois é um erro não crítico - a foto já foi convertida para base64
      }

      return base64Photo;
      
    } catch (e) {
      rethrow;
    }
  }

  /// Abre as configurações do app para o usuário gerenciar permissões
  static Future<bool> openPhotoServiceAppSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      return false;
    }
  }
  
  /// Verifica se a câmera está disponível verificando as permissões
  static Future<bool> isCameraAvailable() async {
    try {
      final status = await Permission.camera.status;
      return status == PermissionStatus.granted || status != PermissionStatus.permanentlyDenied;
    } catch (e) {
      return false;
    }
  }
  
  /// Converte uma string base64 de volta para bytes (para exibir a imagem)
  static Uint8List base64ToBytes(String base64String) {
    return base64Decode(base64String);
  }
}
