import 'package:networking_game/core/constants/app_constants.dart';

class LeaderboardEntry {
  final String userId;
  final String name;
  final int score;
  final int rank;
  final int totalScans;
  final int correctGuesses;
  final int wrongGuesses;
  final double accuracy;
  final int? previousRank;

  LeaderboardEntry({
    required this.userId,
    required this.name,
    required this.score,
    required this.rank,
    required this.totalScans,
    required this.correctGuesses,
    required this.wrongGuesses,
    required this.accuracy,
    this.previousRank,
  });

  String get tier => AppConstants.getRankForScore(score);

  int? get rankChange {
    if (previousRank == null) return null;
    return previousRank! - rank;
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'score': score,
      'rank': rank,
      'totalScans': totalScans,
      'correctGuesses': correctGuesses,
      'wrongGuesses': wrongGuesses,
      'accuracy': accuracy,
      'previousRank': previousRank,
    };
  }

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntry(
      userId: map['userId'] as String? ?? '',
      name: map['name'] as String? ?? 'Unknown',
      score: map['score'] as int? ?? 0,
      rank: map['rank'] as int? ?? 0,
      totalScans: map['totalScans'] as int? ?? 0,
      correctGuesses: map['correctGuesses'] as int? ?? 0,
      wrongGuesses: map['wrongGuesses'] as int? ?? 0,
      accuracy: (map['accuracy'] as num?)?.toDouble() ?? 0,
      previousRank: map['previousRank'] as int?,
    );
  }
}
