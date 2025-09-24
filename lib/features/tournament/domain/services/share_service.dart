import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../entities/tournament.dart';
import 'photo_service.dart';

class ShareService {

  /// Compartilha os times do torneio via WhatsApp (apenas texto)
  static Future<void> shareTournamentTeamsOnWhatsApp(Tournament tournament) async {
    try {
      
      // Criar texto formatado para WhatsApp
      final text = '''
🏆 *${tournament.name}*
📅 ${tournament.date.day}/${tournament.date.month}/${tournament.date.year}

⚽ *${tournament.teams.length} times participando!*

${_buildTeamsText(tournament)}

*Gerado pelo app Fominhas* ⚽
''';

      // Compartilhar apenas texto (mais confiável)
      await Share.share(
        text,
        subject: 'Times do Torneio ${tournament.name}',
      );
      
      
    } catch (e) {
      throw Exception('Erro ao compartilhar times: $e');
    }
  }

  /// "Baixa" a foto compartilhando-a (o usuário pode salvar da conversa)
  static Future<bool> downloadWinnerPhoto(Tournament tournament) async {
    try {
      
      // Compartilhar a foto com instruções para salvar
      await shareWinnerPhotoForDownload(tournament);
      return true;
      
    } catch (e) {
      throw Exception('Erro ao compartilhar foto: $e');
    }
  }

  /// Compartilha a foto do time vencedor especificamente para download
  static Future<void> shareWinnerPhotoForDownload(Tournament tournament) async {
    try {
      
      // Verificar se existe foto do vencedor
      if (tournament.winnerPhotoBase64 == null || tournament.winnerPhotoBase64!.isEmpty) {
        throw Exception('Nenhuma foto do vencedor encontrada');
      }
      
      // Converter base64 para bytes
      final photoBytes = PhotoService.base64ToBytes(tournament.winnerPhotoBase64!);
      
      // Criar arquivo temporário
      final tempDir = await getTemporaryDirectory();
      final fileName = 'campeao_${tournament.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final tempFile = File('${tempDir.path}/$fileName');
      
      // Escrever bytes no arquivo
      await tempFile.writeAsBytes(photoBytes);
      
      // Encontrar o time vencedor
      final winner = tournament.teams.firstWhere(
        (team) => team.id == tournament.championTeamId,
        orElse: () => tournament.teams.first,
      );
      
      // Criar texto para acompanhar a foto com instruções para salvar
      final text = '''
🏆 *FOTO DO CAMPEÃO*
*${winner.name}*

📅 ${tournament.date.day}/${tournament.date.month}/${tournament.date.year}

📥 *Para salvar a foto:*
1. Toque na foto
2. Selecione "Salvar na galeria"
3. Ou use o botão de download do seu app

*Gerado pelo app Fominhas* ⚽
''';

      // Compartilhar
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: text,
        subject: 'Foto do Campeão - ${tournament.name}',
      );
      
      
    } catch (e) {
      throw Exception('Erro ao compartilhar foto: $e');
    }
  }

  /// Compartilha a foto do time vencedor
  static Future<void> shareWinnerPhoto(Tournament tournament) async {
    try {
      
      // Verificar se existe foto do vencedor
      if (tournament.winnerPhotoBase64 == null || tournament.winnerPhotoBase64!.isEmpty) {
        throw Exception('Nenhuma foto do vencedor encontrada');
      }
      
      // Converter base64 para bytes
      final photoBytes = PhotoService.base64ToBytes(tournament.winnerPhotoBase64!);
      
      // Criar arquivo temporário
      final tempDir = await getTemporaryDirectory();
      final fileName = 'winner_${tournament.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final tempFile = File('${tempDir.path}/$fileName');
      
      // Escrever bytes no arquivo
      await tempFile.writeAsBytes(photoBytes);
      
      // Encontrar o time vencedor
      final winner = tournament.teams.firstWhere(
        (team) => team.id == tournament.championTeamId,
        orElse: () => tournament.teams.first,
      );
      
      // Criar texto para acompanhar a foto
      final text = '''
🏆 *CAMPEÃO DO TORNEIO*
*${tournament.name}*

🥇 *${winner.name}*
📊 ${winner.points} pontos
⚽ ${winner.goalsScored} gols marcados
🛡️ ${winner.goalsConceded} gols sofridos
📈 Saldo: ${winner.goalDifference >= 0 ? '+' : ''}${winner.goalDifference}

📅 ${tournament.date.day}/${tournament.date.month}/${tournament.date.year}

*Gerado pelo app Fominhas* ⚽
''';

      // Compartilhar
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: text,
        subject: 'Campeão do Torneio ${tournament.name}',
      );
      
      
    } catch (e) {
      throw Exception('Erro ao compartilhar foto: $e');
    }
  }

  // Note: _requestStoragePermission method removed as it was not referenced


  /// Constrói o texto dos times para compartilhamento
  static String _buildTeamsText(Tournament tournament) {
    final buffer = StringBuffer();
    
    // Ordenar times por pontos se o torneio estiver finalizado
    final teams = [...tournament.teams];
    if (tournament.status == TournamentStatus.finished) {
      teams.sort((a, b) {
        if (a.points != b.points) return b.points.compareTo(a.points);
        if (a.goalDifference != b.goalDifference) return b.goalDifference.compareTo(a.goalDifference);
        return b.goalsScored.compareTo(a.goalsScored);
      });
      
      buffer.writeln('*CLASSIFICAÇÃO FINAL:*');
      for (int i = 0; i < teams.length; i++) {
        final team = teams[i];
        final position = i + 1;
        final emoji = position == 1 ? '🥇' : position == 2 ? '🥈' : position == 3 ? '🥉' : '⚽';
        buffer.writeln('$emoji $position° ${team.name} - ${team.points} pts');
        
        // Adicionar jogadores do time
        if (team.players.isNotEmpty) {
          final playerNames = team.players.map((p) => p.name).join(', ');
          buffer.writeln('   Jogadores: $playerNames');
        }
        buffer.writeln(''); // Linha em branco entre times
      }
    } else {
      buffer.writeln('*TIMES PARTICIPANTES:*\n');
      for (final team in teams) {
        buffer.writeln('⚽ *${team.name}*');
        
        // Adicionar jogadores do time
        if (team.players.isNotEmpty) {
          final playerNames = team.players.map((p) => p.name).join(', ');
          buffer.writeln('   Jogadores: $playerNames');
        }
        buffer.writeln(''); // Linha em branco entre times
      }
    }
    
    return buffer.toString();
  }
}

