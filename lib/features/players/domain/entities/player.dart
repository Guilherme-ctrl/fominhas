import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum PlayerPosition {
  goleiro,
  fixo,
  ala,
  pivo,
}

class Player extends Equatable {
  final String? id;
  final String name;
  final PlayerPosition position;
  final int jerseyNumber;
  final String? email;
  final String? phone;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final PlayerStats stats;

  const Player({
    this.id,
    required this.name,
    required this.position,
    required this.jerseyNumber,
    this.email,
    this.phone,
    required this.createdAt,
    this.updatedAt,
    required this.stats,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'position': position.name,
      'jerseyNumber': jerseyNumber,
      'email': email,
      'phone': phone,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'stats': stats.toJson(),
    };
  }

  factory Player.fromJson(Map<String, dynamic> json, {String? id}) {
    return Player(
      id: id,
      name: json['name'] ?? '',
      position: PlayerPosition.values.firstWhere(
        (p) => p.name == json['position'],
        orElse: () => PlayerPosition.ala,
      ),
      jerseyNumber: json['jerseyNumber'] ?? 0,
      email: json['email'],
      phone: json['phone'],
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
      stats: PlayerStats.fromJson(json['stats'] ?? {}),
    );
  }

  Player copyWith({
    String? id,
    String? name,
    PlayerPosition? position,
    int? jerseyNumber,
    String? email,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
    PlayerStats? stats,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      jerseyNumber: jerseyNumber ?? this.jerseyNumber,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stats: stats ?? this.stats,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    position,
    jerseyNumber,
    email,
    phone,
    createdAt,
    updatedAt,
    stats,
  ];
}

class PlayerStats extends Equatable {
  final int matchesPlayed;
  final int goals;
  final int assists;
  final int yellowCards;
  final int redCards;

  const PlayerStats({
    this.matchesPlayed = 0,
    this.goals = 0,
    this.assists = 0,
    this.yellowCards = 0,
    this.redCards = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'matchesPlayed': matchesPlayed,
      'goals': goals,
      'assists': assists,
      'yellowCards': yellowCards,
      'redCards': redCards,
    };
  }

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      matchesPlayed: json['matchesPlayed'] ?? 0,
      goals: json['goals'] ?? 0,
      assists: json['assists'] ?? 0,
      yellowCards: json['yellowCards'] ?? 0,
      redCards: json['redCards'] ?? 0,
    );
  }

  PlayerStats copyWith({
    int? matchesPlayed,
    int? goals,
    int? assists,
    int? yellowCards,
    int? redCards,
  }) {
    return PlayerStats(
      matchesPlayed: matchesPlayed ?? this.matchesPlayed,
      goals: goals ?? this.goals,
      assists: assists ?? this.assists,
      yellowCards: yellowCards ?? this.yellowCards,
      redCards: redCards ?? this.redCards,
    );
  }

  @override
  List<Object?> get props => [
    matchesPlayed,
    goals,
    assists,
    yellowCards,
    redCards,
  ];
}
