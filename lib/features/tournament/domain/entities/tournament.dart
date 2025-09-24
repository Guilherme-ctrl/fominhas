import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../../players/domain/entities/player.dart';

class Tournament extends Equatable {
  final String? id;
  final String name;
  final DateTime date;
  final List<TournamentTeam> teams;
  final List<TournamentMatch> matches;
  final TournamentStatus status;
  final String? championTeamId;
  final String? winnerPhotoBase64;
  final DateTime? photoTakenAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Tournament({
    this.id,
    required this.name,
    required this.date,
    required this.teams,
    required this.matches,
    this.status = TournamentStatus.setup,
    this.championTeamId,
    this.winnerPhotoBase64,
    this.photoTakenAt,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'date': Timestamp.fromDate(date),
      'teams': teams.map((team) => team.toJson()).toList(),
      'matches': matches.map((match) => match.toJson()).toList(),
      'status': status.name,
      'championTeamId': championTeamId,
      'winnerPhotoBase64': winnerPhotoBase64,
      'photoTakenAt': photoTakenAt != null ? Timestamp.fromDate(photoTakenAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory Tournament.fromJson(Map<String, dynamic> json, {String? id}) {
    return Tournament(
      id: id,
      name: json['name'] ?? '',
      date: (json['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      teams: (json['teams'] as List?)
              ?.map((team) => TournamentTeam.fromJson(team))
              .toList() ??
          [],
      matches: (json['matches'] as List?)
              ?.map((match) => TournamentMatch.fromJson(match))
              .toList() ??
          [],
      status: TournamentStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => TournamentStatus.setup,
      ),
      championTeamId: json['championTeamId'],
      winnerPhotoBase64: json['winnerPhotoBase64'],
      photoTakenAt: (json['photoTakenAt'] as Timestamp?)?.toDate(),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Tournament copyWith({
    String? id,
    String? name,
    DateTime? date,
    List<TournamentTeam>? teams,
    List<TournamentMatch>? matches,
    TournamentStatus? status,
    String? championTeamId,
    String? winnerPhotoBase64,
    DateTime? photoTakenAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Tournament(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      teams: teams ?? this.teams,
      matches: matches ?? this.matches,
      status: status ?? this.status,
      championTeamId: championTeamId ?? this.championTeamId,
      winnerPhotoBase64: winnerPhotoBase64 ?? this.winnerPhotoBase64,
      photoTakenAt: photoTakenAt ?? this.photoTakenAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    date,
    teams,
    matches,
    status,
    championTeamId,
    winnerPhotoBase64,
    photoTakenAt,
    createdAt,
    updatedAt,
  ];
}

class TournamentTeam extends Equatable {
  final String id;
  final String name;
  final List<Player> players;
  final List<Player> reserves;
  final int points;
  final int goalsScored;
  final int goalsConceded;
  final int wins;
  final int draws;
  final int losses;

  const TournamentTeam({
    required this.id,
    required this.name,
    required this.players,
    this.reserves = const [],
    this.points = 0,
    this.goalsScored = 0,
    this.goalsConceded = 0,
    this.wins = 0,
    this.draws = 0,
    this.losses = 0,
  });

  int get goalDifference => goalsScored - goalsConceded;
  int get matchesPlayed => wins + draws + losses;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'players': players.map((player) => player.toJson()).toList(),
      'reserves': reserves.map((player) => player.toJson()).toList(),
      'points': points,
      'goalsScored': goalsScored,
      'goalsConceded': goalsConceded,
      'wins': wins,
      'draws': draws,
      'losses': losses,
    };
  }

  factory TournamentTeam.fromJson(Map<String, dynamic> json) {
    return TournamentTeam(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      players: (json['players'] as List?)
              ?.map((player) => Player.fromJson(player))
              .toList() ??
          [],
      reserves: (json['reserves'] as List?)
              ?.map((player) => Player.fromJson(player))
              .toList() ??
          [],
      points: json['points'] ?? 0,
      goalsScored: json['goalsScored'] ?? 0,
      goalsConceded: json['goalsConceded'] ?? 0,
      wins: json['wins'] ?? 0,
      draws: json['draws'] ?? 0,
      losses: json['losses'] ?? 0,
    );
  }

  TournamentTeam copyWith({
    String? id,
    String? name,
    List<Player>? players,
    List<Player>? reserves,
    int? points,
    int? goalsScored,
    int? goalsConceded,
    int? wins,
    int? draws,
    int? losses,
  }) {
    return TournamentTeam(
      id: id ?? this.id,
      name: name ?? this.name,
      players: players ?? this.players,
      reserves: reserves ?? this.reserves,
      points: points ?? this.points,
      goalsScored: goalsScored ?? this.goalsScored,
      goalsConceded: goalsConceded ?? this.goalsConceded,
      wins: wins ?? this.wins,
      draws: draws ?? this.draws,
      losses: losses ?? this.losses,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    players,
    reserves,
    points,
    goalsScored,
    goalsConceded,
    wins,
    draws,
    losses,
  ];
}

class TournamentMatch extends Equatable {
  final String id;
  final String homeTeamId;
  final String awayTeamId;
  final int homeScore;
  final int awayScore;
  final int matchNumber; // 1, 2, 3 ou 4
  final TournamentMatchStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final int elapsedMinutes;
  final int elapsedSeconds;
  final List<TournamentMatchEvent> events;

  const TournamentMatch({
    required this.id,
    required this.homeTeamId,
    required this.awayTeamId,
    this.homeScore = 0,
    this.awayScore = 0,
    required this.matchNumber,
    this.status = TournamentMatchStatus.scheduled,
    this.startTime,
    this.endTime,
    this.elapsedMinutes = 0,
    this.elapsedSeconds = 0,
    this.events = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'homeTeamId': homeTeamId,
      'awayTeamId': awayTeamId,
      'homeScore': homeScore,
      'awayScore': awayScore,
      'matchNumber': matchNumber,
      'status': status.name,
      'startTime': startTime != null ? Timestamp.fromDate(startTime!) : null,
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'elapsedMinutes': elapsedMinutes,
      'elapsedSeconds': elapsedSeconds,
      'events': events.map((event) => event.toJson()).toList(),
    };
  }

  factory TournamentMatch.fromJson(Map<String, dynamic> json) {
    return TournamentMatch(
      id: json['id'] ?? '',
      homeTeamId: json['homeTeamId'] ?? '',
      awayTeamId: json['awayTeamId'] ?? '',
      homeScore: json['homeScore'] ?? 0,
      awayScore: json['awayScore'] ?? 0,
      matchNumber: json['matchNumber'] ?? 1,
      status: TournamentMatchStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => TournamentMatchStatus.scheduled,
      ),
      startTime: (json['startTime'] as Timestamp?)?.toDate(),
      endTime: (json['endTime'] as Timestamp?)?.toDate(),
      elapsedMinutes: json['elapsedMinutes'] ?? 0,
      elapsedSeconds: json['elapsedSeconds'] ?? 0,
      events: (json['events'] as List?)
              ?.map((event) => TournamentMatchEvent.fromJson(event))
              .toList() ??
          [],
    );
  }

  TournamentMatch copyWith({
    String? id,
    String? homeTeamId,
    String? awayTeamId,
    int? homeScore,
    int? awayScore,
    int? matchNumber,
    TournamentMatchStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    int? elapsedMinutes,
    int? elapsedSeconds,
    List<TournamentMatchEvent>? events,
  }) {
    return TournamentMatch(
      id: id ?? this.id,
      homeTeamId: homeTeamId ?? this.homeTeamId,
      awayTeamId: awayTeamId ?? this.awayTeamId,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      matchNumber: matchNumber ?? this.matchNumber,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      elapsedMinutes: elapsedMinutes ?? this.elapsedMinutes,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      events: events ?? this.events,
    );
  }

  @override
  List<Object?> get props => [
    id,
    homeTeamId,
    awayTeamId,
    homeScore,
    awayScore,
    matchNumber,
    status,
    startTime,
    endTime,
    elapsedMinutes,
    elapsedSeconds,
    events,
  ];
}

class TournamentMatchEvent extends Equatable {
  final String id;
  final String playerId;
  final String playerName;
  final String? assistPlayerId;
  final String? assistPlayerName;
  final String teamId;
  final int minute;
  final int second;
  final TournamentMatchEventType type;

  const TournamentMatchEvent({
    required this.id,
    required this.playerId,
    required this.playerName,
    this.assistPlayerId,
    this.assistPlayerName,
    required this.teamId,
    required this.minute,
    required this.second,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'playerId': playerId,
      'playerName': playerName,
      'assistPlayerId': assistPlayerId,
      'assistPlayerName': assistPlayerName,
      'teamId': teamId,
      'minute': minute,
      'second': second,
      'type': type.name,
    };
  }

  factory TournamentMatchEvent.fromJson(Map<String, dynamic> json) {
    return TournamentMatchEvent(
      id: json['id'] ?? '',
      playerId: json['playerId'] ?? '',
      playerName: json['playerName'] ?? '',
      assistPlayerId: json['assistPlayerId'],
      assistPlayerName: json['assistPlayerName'],
      teamId: json['teamId'] ?? '',
      minute: json['minute'] ?? 0,
      second: json['second'] ?? 0,
      type: TournamentMatchEventType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => TournamentMatchEventType.goal,
      ),
    );
  }

  @override
  List<Object?> get props => [
    id,
    playerId,
    playerName,
    assistPlayerId,
    assistPlayerName,
    teamId,
    minute,
    second,
    type,
  ];
}

enum TournamentStatus {
  setup,      // Configuração inicial
  inProgress, // Torneio em andamento
  finished,   // Torneio finalizado
}

enum TournamentMatchStatus {
  scheduled,  // Agendada
  inProgress, // Em andamento
  paused,     // Pausada
  finished,   // Finalizada
}

enum TournamentMatchEventType {
  goal,       // Gol
  assist,     // Assistência (já incluída no gol)
}