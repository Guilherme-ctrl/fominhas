import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/tournament.dart';
import '../../domain/services/tournament_service.dart';

class MatchTimer extends StatefulWidget {
  final TournamentMatch match;
  final Function(TournamentMatch) onMatchUpdated;
  final VoidCallback? onMatchFinished;

  const MatchTimer({
    super.key,
    required this.match,
    required this.onMatchUpdated,
    this.onMatchFinished,
  });

  @override
  State<MatchTimer> createState() => _MatchTimerState();
}

class _MatchTimerState extends State<MatchTimer> {
  Timer? _timer;
  int _elapsedMinutes = 0;
  int _elapsedSeconds = 0;
  bool _isRunning = false;
  static const int _matchDurationMinutes = 9;

  @override
  void initState() {
    super.initState();
    _elapsedMinutes = widget.match.elapsedMinutes;
    _elapsedSeconds = widget.match.elapsedSeconds;
    _isRunning = widget.match.status == TournamentMatchStatus.inProgress;
    
    if (_isRunning) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(MatchTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Atualizar estado local com dados da nova partida se mudou
    if (oldWidget.match.id != widget.match.id ||
        oldWidget.match.elapsedMinutes != widget.match.elapsedMinutes ||
        oldWidget.match.elapsedSeconds != widget.match.elapsedSeconds ||
        oldWidget.match.status != widget.match.status) {
      
      _elapsedMinutes = widget.match.elapsedMinutes;
      _elapsedSeconds = widget.match.elapsedSeconds;
      
      // Se a partida está em andamento, garantir que o timer está rodando
      if (widget.match.status == TournamentMatchStatus.inProgress && !_isRunning) {
        _isRunning = true;
        _startTimer();
      } else if (widget.match.status != TournamentMatchStatus.inProgress && _isRunning) {
        _timer?.cancel();
        _isRunning = false;
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    
    // Cancelar timer anterior se existir
    _timer?.cancel();
    
    if (_isRunning) {
    } else {
      setState(() {
        _isRunning = true;
      });
      // Atualizar status da partida para "em andamento"
      _updateMatchStatus(TournamentMatchStatus.inProgress);
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
        if (_elapsedSeconds >= 60) {
          _elapsedSeconds = 0;
          _elapsedMinutes++;
        }
      });

      // Atualizar partida com novo tempo apenas a cada 5 segundos
      if (_elapsedSeconds % 5 == 0) {
        _updateMatchTime();
      }

      // Verificar se chegou aos 9 minutos
      if (_elapsedMinutes >= _matchDurationMinutes) {
        _finishMatch();
      }
    });
  }

  void _pauseTimer() {
    if (!_isRunning) return;

    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });

    // Atualizar status da partida para "pausada"
    _updateMatchStatus(TournamentMatchStatus.paused);
  }

  void _resumeTimer() {
    if (_isRunning || _elapsedMinutes >= _matchDurationMinutes) return;
    _startTimer();
  }

  void _finishMatch() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _elapsedMinutes = _matchDurationMinutes;
      _elapsedSeconds = 0;
    });

    // Atualizar status da partida para "finalizada"
    _updateMatchStatus(TournamentMatchStatus.finished);
    
    // Notificar que a partida terminou
    widget.onMatchFinished?.call();
  }

  void _updateMatchTime() {
    // Só atualizar se o tempo mudou
    if (widget.match.elapsedMinutes != _elapsedMinutes || 
        widget.match.elapsedSeconds != _elapsedSeconds) {
      final updatedMatch = widget.match.copyWith(
        elapsedMinutes: _elapsedMinutes,
        elapsedSeconds: _elapsedSeconds,
      );
      widget.onMatchUpdated(updatedMatch);
    }
  }

  void _updateMatchStatus(TournamentMatchStatus status) {
    final updatedMatch = widget.match.copyWith(
      status: status,
      elapsedMinutes: _elapsedMinutes,
      elapsedSeconds: _elapsedSeconds,
      startTime: status == TournamentMatchStatus.inProgress && widget.match.startTime == null
          ? DateTime.now()
          : widget.match.startTime,
      endTime: status == TournamentMatchStatus.finished
          ? DateTime.now()
          : widget.match.endTime,
    );
    widget.onMatchUpdated(updatedMatch);
  }

  Widget _buildTimeDisplay() {
    final timeString = TournamentService.formatMatchTime(_elapsedMinutes, _elapsedSeconds);
    final isNearEnd = _elapsedMinutes >= _matchDurationMinutes - 1; // Último minuto
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive sizing based on screen width
    final isSmallScreen = screenWidth < 400;
    final timeFontSize = isSmallScreen ? 24.0 : 32.0;
    final horizontalPadding = isSmallScreen ? 12.0 : 20.0;
    final verticalPadding = isSmallScreen ? 8.0 : 12.0;
    final subtitleFontSize = isSmallScreen ? 12.0 : 14.0;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      decoration: BoxDecoration(
        color: isNearEnd 
          ? Theme.of(context).colorScheme.errorContainer
          : Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              timeString,
              style: TextStyle(
                fontSize: timeFontSize,
                fontWeight: FontWeight.bold,
                color: isNearEnd 
                  ? Theme.of(context).colorScheme.onErrorContainer
                  : Theme.of(context).colorScheme.onPrimaryContainer,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Text(
            'Partida ${widget.match.matchNumber}',
            style: TextStyle(
              fontSize: subtitleFontSize,
              color: isNearEnd 
                ? Theme.of(context).colorScheme.onErrorContainer
                : Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    final isFinished = widget.match.status == TournamentMatchStatus.finished ||
                     _elapsedMinutes >= _matchDurationMinutes;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    if (isFinished) {
      return Container(
        padding: EdgeInsets.all(isSmallScreen ? 8.0 : 12.0),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade700),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Partida Finalizada',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                  fontSize: isSmallScreen ? 12.0 : 14.0,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    // Use Wrap for small screens to prevent overflow
    if (isSmallScreen) {
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          if (!_isRunning) ...[
            ElevatedButton.icon(
              onPressed: _resumeTimer,
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text('Iniciar', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: const Size(0, 36),
              ),
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: _pauseTimer,
              icon: const Icon(Icons.pause, size: 18),
              label: const Text('Pausar', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: const Size(0, 36),
              ),
            ),
          ],
          ElevatedButton.icon(
            onPressed: _finishMatch,
            icon: const Icon(Icons.stop, size: 18),
            label: const Text('Finalizar', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
          ),
        ],
      );
    }

    // Use Row for larger screens
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!_isRunning) ...[
          ElevatedButton.icon(
            onPressed: _resumeTimer,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Iniciar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ] else ...[
          ElevatedButton.icon(
            onPressed: _pauseTimer,
            icon: const Icon(Icons.pause),
            label: const Text('Pausar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _finishMatch,
          icon: const Icon(Icons.stop),
          label: const Text('Finalizar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    final progress = (_elapsedMinutes * 60 + _elapsedSeconds) / (_matchDurationMinutes * 60);
    final clampedProgress = progress.clamp(0.0, 1.0);
    
    return Column(
      children: [
        LinearProgressIndicator(
          value: clampedProgress,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(
            clampedProgress >= 0.9 
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.primary,
          ),
          minHeight: 6,
        ),
        const SizedBox(height: 4),
        Text(
          '${(clampedProgress * 100).toInt()}% concluído',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final cardPadding = isSmallScreen ? 12.0 : 20.0;
    final cardMargin = isSmallScreen ? 8.0 : 16.0;
    final spacing = isSmallScreen ? 12.0 : 16.0;
    final largeSpacing = isSmallScreen ? 16.0 : 20.0;
    
    return Container(
      margin: EdgeInsets.all(cardMargin),
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildTimeDisplay(),
          SizedBox(height: spacing),
          _buildProgressBar(),
          SizedBox(height: largeSpacing),
          _buildControlButtons(),
        ],
      ),
    );
  }
}