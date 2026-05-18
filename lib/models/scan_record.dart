import 'package:cloud_firestore/cloud_firestore.dart';

class ScanRecord {
  final String id;
  final String scannerId;
  final String scannedId;
  final DateTime timestamp;
  final bool answered;
  final bool? correct;

  ScanRecord({
    required this.id,
    required this.scannerId,
    required this.scannedId,
    DateTime? timestamp,
    this.answered = false,
    this.correct,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'scannerId': scannerId,
      'scannedId': scannedId,
      'timestamp': Timestamp.fromDate(timestamp),
      'answered': answered,
      'correct': correct,
    };
  }

  factory ScanRecord.fromMap(Map<String, dynamic> map, String id) {
    return ScanRecord(
      id: id,
      scannerId: map['scannerId'] as String? ?? '',
      scannedId: map['scannedId'] as String? ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      answered: map['answered'] as bool? ?? false,
      correct: map['correct'] as bool?,
    );
  }
}
