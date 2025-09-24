import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../entities/tournament.dart';

class InstagramService {
  
  /// Compartilha torneio no Instagram via compartilhamento nativo
  static Future<void> shareToInstagram(String content, {String? imagePath}) async {
    try {
      
      final List<XFile> files = [];
      if (imagePath != null) {
        files.add(XFile(imagePath));
      }
      
      // Tentar abrir Instagram primeiro, se falhar usar compartilhamento geral
      await _tryShareToInstagram(files, content);
      
    } catch (e) {
      throw Exception('Erro ao compartilhar no Instagram: $e');
    }
  }
  
  /// Tenta compartilhar especificamente no Instagram
  static Future<void> _tryShareToInstagram(List<XFile> files, String content) async {
    try {
      // Primeiro tentar abrir o Instagram diretamente
      final Uri instagramUrl = Uri.parse('instagram://');
      
      if (await canLaunchUrl(instagramUrl)) {
        // Instagram instalado, usar compartilhamento com sugestão
        await Share.shareXFiles(
          files,
          text: content,
          subject: 'Fominhas - Torneio de Futebol ⚽',
        );
      } else {
        // Instagram não instalado, sugerir instalação
        throw Exception('Instagram não instalado. Instale o Instagram para usar esta funcionalidade.');
      }
    } catch (e) {
      // Fallback para compartilhamento geral
      await Share.shareXFiles(
        files,
        text: content,
        subject: 'Fominhas - Torneio de Futebol ⚽',
      );
    }
  }
  
  /// Gera imagem para Instagram Stories (9:16)
  static Future<String?> generateInstagramStoryImage(Tournament tournament) async {
    try {
      
      // Vamos gerar uma imagem usando Canvas personalizado
      const double width = 1080;
      const double height = 1920;
      
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      
      // Background gradiente
      final gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF0D1117), // Dark background
          const Color(0xFF161B22), // Slightly lighter
          const Color(0xFF21262D), // Card color
        ],
      );
      
      final paint = Paint()..shader = gradient.createShader(Rect.fromLTWH(0, 0, width, height));
      canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);
      
      // Título
      _drawText(
        canvas,
        '⚽ FOMINHAS',
        const Offset(width / 2, 200),
        const TextStyle(
          color: Color(0xFF00D4AA),
          fontSize: 60,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      );
      
      // Nome do torneio
      _drawText(
        canvas,
        tournament.name,
        const Offset(width / 2, 320),
        const TextStyle(
          color: Color(0xFFE6EDF3),
          fontSize: 48,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      );
      
      // Data
      _drawText(
        canvas,
        '${tournament.date.day}/${tournament.date.month}/${tournament.date.year}',
        const Offset(width / 2, 420),
        const TextStyle(
          color: Color(0xFF8B949E),
          fontSize: 32,
        ),
        textAlign: TextAlign.center,
      );
      
      // Times participantes
      double yPosition = 580;
      _drawText(
        canvas,
        '${tournament.teams.length} TIMES PARTICIPANDO',
        Offset(width / 2, yPosition),
        const TextStyle(
          color: Color(0xFF00D4AA),
          fontSize: 36,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      );
      
      yPosition += 120;
      for (final team in tournament.teams) {
        _drawText(
          canvas,
          '⚽ ${team.name}',
          Offset(width / 2, yPosition),
          const TextStyle(
            color: Color(0xFFE6EDF3),
            fontSize: 42,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        );
        yPosition += 80;
      }
      
      // Se torneio finalizado, mostrar campeão
      if (tournament.status == TournamentStatus.finished && tournament.championTeamId != null) {
        final winner = tournament.teams.firstWhere((t) => t.id == tournament.championTeamId);
        
        yPosition += 60;
        _drawText(
          canvas,
          '🏆 CAMPEÃO',
          Offset(width / 2, yPosition),
          const TextStyle(
            color: Color(0xFFD29922),
            fontSize: 44,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        );
        
        yPosition += 80;
        _drawText(
          canvas,
          winner.name,
          Offset(width / 2, yPosition),
          const TextStyle(
            color: Color(0xFF00D4AA),
            fontSize: 52,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        );
      }
      
      // Footer
      _drawText(
        canvas,
        'Gerado pelo app Fominhas ⚽',
        Offset(width / 2, height - 100),
        const TextStyle(
          color: Color(0xFF656D76),
          fontSize: 28,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      );
      
      // Finalizar imagem
      final picture = recorder.endRecording();
      final img = await picture.toImage(width.round(), height.round());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) return null;
      
      // Salvar arquivo
      final tempDir = await getTemporaryDirectory();
      final fileName = 'instagram_story_${tournament.id}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      
      return file.path;
      
    } catch (e) {
      return null;
    }
  }
  
  /// Gera imagem para Feed do Instagram (1:1 - quadrada)
  static Future<String?> generateInstagramFeedImage(Tournament tournament) async {
    try {
      
      const double size = 1080; // Quadrado 1:1
      
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      
      // Background gradiente
      final gradient = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          const Color(0xFF21262D),
          const Color(0xFF161B22),
          const Color(0xFF0D1117),
        ],
      );
      
      final paint = Paint()..shader = gradient.createShader(Rect.fromLTWH(0, 0, size, size));
      canvas.drawRect(Rect.fromLTWH(0, 0, size, size), paint);
      
      // Logo/Título
      _drawText(
        canvas,
        'FOMINHAS ⚽',
        const Offset(size / 2, 150),
        const TextStyle(
          color: Color(0xFF00D4AA),
          fontSize: 72,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      );
      
      // Nome do torneio
      _drawText(
        canvas,
        tournament.name,
        const Offset(size / 2, 280),
        const TextStyle(
          color: Color(0xFFE6EDF3),
          fontSize: 54,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      );
      
      // Data
      _drawText(
        canvas,
        '${tournament.date.day}/${tournament.date.month}/${tournament.date.year}',
        const Offset(size / 2, 360),
        const TextStyle(
          color: Color(0xFF8B949E),
          fontSize: 36,
        ),
        textAlign: TextAlign.center,
      );
      
      // Informações centrais
      double yPosition = 480;
      
      if (tournament.status == TournamentStatus.finished) {
        // Torneio finalizado - mostrar resultado
        final winner = tournament.teams.firstWhere(
          (t) => t.id == tournament.championTeamId,
          orElse: () => tournament.teams.first,
        );
        
        _drawText(
          canvas,
          '🏆 TORNEIO FINALIZADO',
          Offset(size / 2, yPosition),
          const TextStyle(
            color: Color(0xFFD29922),
            fontSize: 42,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        );
        
        yPosition += 100;
        _drawText(
          canvas,
          'CAMPEÃO',
          Offset(size / 2, yPosition),
          const TextStyle(
            color: Color(0xFF00D4AA),
            fontSize: 38,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        );
        
        yPosition += 70;
        _drawText(
          canvas,
          winner.name,
          Offset(size / 2, yPosition),
          const TextStyle(
            color: Color(0xFFE6EDF3),
            fontSize: 56,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        );
        
        yPosition += 80;
        _drawText(
          canvas,
          '${winner.points} pontos • ${winner.goalsScored} gols',
          Offset(size / 2, yPosition),
          const TextStyle(
            color: Color(0xFF8B949E),
            fontSize: 32,
          ),
          textAlign: TextAlign.center,
        );
        
      } else {
        // Torneio em andamento
        _drawText(
          canvas,
          '${tournament.teams.length} TIMES',
          Offset(size / 2, yPosition),
          const TextStyle(
            color: Color(0xFF00D4AA),
            fontSize: 48,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        );
        
        yPosition += 80;
        _drawText(
          canvas,
          '${tournament.matches.length} PARTIDAS',
          Offset(size / 2, yPosition),
          const TextStyle(
            color: Color(0xFFE6EDF3),
            fontSize: 42,
          ),
          textAlign: TextAlign.center,
        );
        
        yPosition += 100;
        final statusText = tournament.status == TournamentStatus.inProgress ? 
          'EM ANDAMENTO' : 'AGUARDANDO INÍCIO';
        _drawText(
          canvas,
          statusText,
          Offset(size / 2, yPosition),
          const TextStyle(
            color: Color(0xFFD29922),
            fontSize: 36,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        );
      }
      
      // Footer
      _drawText(
        canvas,
        '#fominhas #futebol #torneio',
        Offset(size / 2, size - 80),
        const TextStyle(
          color: Color(0xFF656D76),
          fontSize: 28,
        ),
        textAlign: TextAlign.center,
      );
      
      // Finalizar imagem
      final picture = recorder.endRecording();
      final img = await picture.toImage(size.round(), size.round());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) return null;
      
      // Salvar arquivo
      final tempDir = await getTemporaryDirectory();
      final fileName = 'instagram_feed_${tournament.id}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      
      return file.path;
      
    } catch (e) {
      return null;
    }
  }
  
  /// Função auxiliar para desenhar texto no canvas
  static void _drawText(Canvas canvas, String text, Offset position, TextStyle style, {TextAlign textAlign = TextAlign.left}) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: textAlign,
    );
    
    textPainter.layout();
    
    // Centralizar o texto na posição especificada
    final offset = Offset(
      position.dx - (textPainter.width / 2),
      position.dy - (textPainter.height / 2),
    );
    
    textPainter.paint(canvas, offset);
  }
  
  /// Compartilha torneio como Instagram Story
  static Future<void> shareAsInstagramStory(Tournament tournament) async {
    try {
      
      final imagePath = await generateInstagramStoryImage(tournament);
      if (imagePath == null) {
        throw Exception('Erro ao gerar imagem para Story');
      }
      
      final caption = '''
🏆 ${tournament.name}
📅 ${tournament.date.day}/${tournament.date.month}/${tournament.date.year}

⚽ ${tournament.teams.length} times participando!

#fominhas #futebol #torneio #story
      ''';
      
      await shareToInstagram(caption, imagePath: imagePath);
      
    } catch (e) {
      throw Exception('Erro ao compartilhar Story: $e');
    }
  }
  
  /// Compartilha torneio como post do Instagram (Feed)
  static Future<void> shareAsInstagramPost(Tournament tournament) async {
    try {
      
      final imagePath = await generateInstagramFeedImage(tournament);
      if (imagePath == null) {
        throw Exception('Erro ao gerar imagem para Feed');
      }
      
      String caption;
      if (tournament.status == TournamentStatus.finished) {
        final winner = tournament.teams.firstWhere(
          (t) => t.id == tournament.championTeamId,
          orElse: () => tournament.teams.first,
        );
        
        caption = '''
🏆 TORNEIO FINALIZADO!

${tournament.name}
📅 ${tournament.date.day}/${tournament.date.month}/${tournament.date.year}

🥇 CAMPEÃO: ${winner.name}
📊 ${winner.points} pontos
⚽ ${winner.goalsScored} gols marcados
🛡️ ${winner.goalsConceded} gols sofridos

Parabéns ao time campeão! 🎉

#fominhas #futebol #torneio #campeao #soccer
        ''';
      } else {
        final teamsList = tournament.teams.map((t) => '⚽ ${t.name}').join('\n');
        
        caption = '''
⚽ NOVO TORNEIO!

${tournament.name}
📅 ${tournament.date.day}/${tournament.date.month}/${tournament.date.year}

${tournament.teams.length} times participando:
$teamsList

${tournament.matches.length} partidas programadas
🔥 Que comecem os jogos!

#fominhas #futebol #torneio #soccer #novotorneio
        ''';
      }
      
      await shareToInstagram(caption, imagePath: imagePath);
      
    } catch (e) {
      throw Exception('Erro ao compartilhar Post: $e');
    }
  }
  
  /// Verifica se o Instagram está instalado
  static Future<bool> isInstagramInstalled() async {
    try {
      final Uri instagramUrl = Uri.parse('instagram://');
      return await canLaunchUrl(instagramUrl);
    } catch (e) {
      return false;
    }
  }
}