import 'package:cloud_firestore/cloud_firestore.dart';

class GameAnswer {
  final String id;
  final String guesserId;
  final String targetId;
  final String selectedStatement;
  final bool isCorrect;
  final DateTime timestamp;
  final int pointsAwarded;

  GameAnswer({
    required this.id,
    required this.guesserId,
    required this.targetId,
    required this.selectedStatement,
    required this.isCorrect,
    DateTime? timestamp,
    required this.pointsAwarded,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'guesserId': guesserId,
      'targetId': targetId,
      'selectedStatement': selectedStatement,
      'isCorrect': isCorrect,
      'timestamp': Timestamp.fromDate(timestamp),
      'pointsAwarded': pointsAwarded,
    };
  }

  factory GameAnswer.fromMap(Map<String, dynamic> map, String id) {
    return GameAnswer(
      id: id,
      guesserId: map['guesserId'] as String? ?? '',
      targetId: map['targetId'] as String? ?? '',
      selectedStatement: map['selectedStatement'] as String? ?? '',
      isCorrect: map['isCorrect'] as bool? ?? false,
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      pointsAwarded: map['pointsAwarded'] as int? ?? 0,
    );
  }
}
