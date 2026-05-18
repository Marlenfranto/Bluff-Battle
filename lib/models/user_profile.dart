import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:networking_game/core/constants/app_constants.dart';

class UserProfile {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String linkedInUrl;
  final String truth1;
  final String truth2;
  final String lie;
  final int score;
  final int totalScans;
  final int correctGuesses;
  final int wrongGuesses;
  final List<String> connections;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    required this.linkedInUrl,
    required this.truth1,
    required this.truth2,
    required this.lie,
    this.score = 0,
    this.totalScans = 0,
    this.correctGuesses = 0,
    this.wrongGuesses = 0,
    this.connections = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get rank => AppConstants.getRankForScore(score);

  double get accuracy {
    final total = correctGuesses + wrongGuesses;
    if (total == 0) return 0;
    return (correctGuesses / total) * 100;
  }

  bool get hasCompletedProfile =>
      name.isNotEmpty &&
      linkedInUrl.isNotEmpty &&
      truth1.isNotEmpty &&
      truth2.isNotEmpty &&
      lie.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'linkedInUrl': linkedInUrl,
      'truth1': truth1,
      'truth2': truth2,
      'lie': lie,
      'score': score,
      'totalScans': totalScans,
      'correctGuesses': correctGuesses,
      'wrongGuesses': wrongGuesses,
      'connections': connections,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String id) {
    return UserProfile(
      id: id,
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      linkedInUrl: map['linkedInUrl'] as String? ?? '',
      truth1: map['truth1'] as String? ?? '',
      truth2: map['truth2'] as String? ?? '',
      lie: map['lie'] as String? ?? '',
      score: map['score'] as int? ?? 0,
      totalScans: map['totalScans'] as int? ?? 0,
      correctGuesses: map['correctGuesses'] as int? ?? 0,
      wrongGuesses: map['wrongGuesses'] as int? ?? 0,
      connections: List<String>.from(map['connections'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory UserProfile.empty(String id) {
    return UserProfile(
      id: id,
      name: '',
      linkedInUrl: '',
      truth1: '',
      truth2: '',
      lie: '',
    );
  }

  UserProfile copyWith({
    String? name,
    String? phone,
    String? email,
    String? linkedInUrl,
    String? truth1,
    String? truth2,
    String? lie,
    int? score,
    int? totalScans,
    int? correctGuesses,
    int? wrongGuesses,
    List<String>? connections,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      linkedInUrl: linkedInUrl ?? this.linkedInUrl,
      truth1: truth1 ?? this.truth1,
      truth2: truth2 ?? this.truth2,
      lie: lie ?? this.lie,
      score: score ?? this.score,
      totalScans: totalScans ?? this.totalScans,
      correctGuesses: correctGuesses ?? this.correctGuesses,
      wrongGuesses: wrongGuesses ?? this.wrongGuesses,
      connections: connections ?? this.connections,
      createdAt: createdAt,
    );
  }
}
