import 'package:cloud_firestore/cloud_firestore.dart';

class Match {
  final String? id;
  final String homeTeam;
  final String awayTeam;
  final int homeScore;
  final int awayScore;
  final DateTime matchDate;
  final String venue;
  final MatchStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<MatchEvent> events;

  const Match({
    this.id,
    required this.homeTeam,
    required this.awayTeam,
    this.homeScore = 0,
    this.awayScore = 0,
    required this.matchDate,
    required this.venue,
    this.status = MatchStatus.scheduled,
    required this.createdAt,
    this.updatedAt,
    this.events = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
      'homeScore': homeScore,
      'awayScore': awayScore,
      'matchDate': Timestamp.fromDate(matchDate),
      'venue': venue,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'events': events.map((e) => e.toJson()).toList(),
    };
  }

  factory Match.fromJson(Map<String, dynamic> json, {String? id}) {
    return Match(
      id: id,
      homeTeam: json['homeTeam'] ?? '',
      awayTeam: json['awayTeam'] ?? '',
      homeScore: json['homeScore'] ?? 0,
      awayScore: json['awayScore'] ?? 0,
      matchDate: (json['matchDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      venue: json['venue'] ?? '',
      status: MatchStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => MatchStatus.scheduled,
      ),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
      events: (json['events'] as List?)
              ?.map((e) => MatchEvent.fromJson(e))
              .toList() ??
          [],
    );
  }

  Match copyWith({
    String? id,
    String? homeTeam,
    String? awayTeam,
    int? homeScore,
    int? awayScore,
    DateTime? matchDate,
    String? venue,
    MatchStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<MatchEvent>? events,
  }) {
    return Match(
      id: id ?? this.id,
      homeTeam: homeTeam ?? this.homeTeam,
      awayTeam: awayTeam ?? this.awayTeam,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      matchDate: matchDate ?? this.matchDate,
      venue: venue ?? this.venue,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      events: events ?? this.events,
    );
  }
}

enum MatchStatus {
  scheduled,
  inProgress,
  finished,
  cancelled,
}

class MatchEvent {
  final String type; // 'goal', 'yellow_card', 'red_card', 'substitution'
  final String playerId;
  final String playerName;
  final int minute;
  final String? team; // 'home' or 'away'
  final String? description;

  const MatchEvent({
    required this.type,
    required this.playerId,
    required this.playerName,
    required this.minute,
    this.team,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'playerId': playerId,
      'playerName': playerName,
      'minute': minute,
      'team': team,
      'description': description,
    };
  }

  factory MatchEvent.fromJson(Map<String, dynamic> json) {
    return MatchEvent(
      type: json['type'] ?? '',
      playerId: json['playerId'] ?? '',
      playerName: json['playerName'] ?? '',
      minute: json['minute'] ?? 0,
      team: json['team'],
      description: json['description'],
    );
  }
}