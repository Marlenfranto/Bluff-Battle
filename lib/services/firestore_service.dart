import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:networking_game/core/constants/app_constants.dart';
import 'package:networking_game/models/user_profile.dart';
import 'package:networking_game/models/scan_record.dart';
import 'package:networking_game/models/game_answer.dart';
import 'package:networking_game/models/leaderboard_entry.dart';

class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _users => _db.collection(AppConstants.usersCollection);
  CollectionReference get _scans => _db.collection(AppConstants.scansCollection);
  CollectionReference get _answers =>
      _db.collection(AppConstants.answersCollection);

  // ─── User Profile ───────────────────────────────────────

  Future<void> createUserProfile(UserProfile profile) async {
    await _users.doc(profile.id).set(profile.toMap());
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _users.doc(userId).get();
      if (!doc.exists) return null;
      return UserProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    await _users.doc(userId).update(data);
  }

  Stream<UserProfile?> userProfileStream(String userId) {
    return _users.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    });
  }

  // ─── Scan Operations ───────────────────────────────────

  Future<bool> checkIfScanned(String scannerId, String scannedId) async {
    final query = await _scans
        .where('scannerId', isEqualTo: scannerId)
        .where('scannedId', isEqualTo: scannedId)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  Future<void> recordScan(ScanRecord scan) async {
    await _scans.doc(scan.id).set(scan.toMap());
  }

  Stream<List<ScanRecord>> getUserScanHistory(String userId) {
    return _scans
        .where('scannerId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) =>
                ScanRecord.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  // ─── Answer Operations ─────────────────────────────────

  Future<void> recordAnswer(GameAnswer answer) async {
    await _answers.doc(answer.id).set(answer.toMap());
  }

  Future<bool> checkIfAnswered(String guesserId, String targetId) async {
    final query = await _answers
        .where('guesserId', isEqualTo: guesserId)
        .where('targetId', isEqualTo: targetId)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  // ─── Score Operations ──────────────────────────────────

  Future<void> updateScore(
      String userId, int pointsDelta, bool correct) async {
    await _users.doc(userId).update({
      'score': FieldValue.increment(pointsDelta),
      'totalScans': FieldValue.increment(1),
      if (correct) 'correctGuesses': FieldValue.increment(1),
      if (!correct) 'wrongGuesses': FieldValue.increment(1),
    });
  }

  // ─── Connection Operations ─────────────────────────────

  Future<void> addConnection(String userId, String connectionId) async {
    // Only update the current user's connections list.
    // The reverse connection is added when the other user scans back.
    await _users.doc(userId).update({
      'connections': FieldValue.arrayUnion([connectionId]),
    });
  }

  Stream<List<UserProfile>> getConnections(String userId) {
    return _users.doc(userId).snapshots().asyncMap((doc) async {
      if (!doc.exists) return <UserProfile>[];
      final data = doc.data() as Map<String, dynamic>;
      final connectionIds = List<String>.from(data['connections'] ?? []);
      if (connectionIds.isEmpty) return <UserProfile>[];

      final profiles = <UserProfile>[];
      // Fetch in batches of 10 (Firestore whereIn limit)
      for (var i = 0; i < connectionIds.length; i += 10) {
        final batch = connectionIds.skip(i).take(10).toList();
        final snap = await _users.where(FieldPath.documentId, whereIn: batch).get();
        for (final d in snap.docs) {
          profiles.add(
              UserProfile.fromMap(d.data() as Map<String, dynamic>, d.id));
        }
      }
      return profiles;
    });
  }

  // ─── Leaderboard ───────────────────────────────────────

  Stream<List<LeaderboardEntry>> getLeaderboard() {
    return _users
        .orderBy('score', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) {
      final entries = <LeaderboardEntry>[];
      for (var i = 0; i < snap.docs.length; i++) {
        final data = snap.docs[i].data() as Map<String, dynamic>;
        final totalGuesses =
            (data['correctGuesses'] as int? ?? 0) +
            (data['wrongGuesses'] as int? ?? 0);
        final accuracy = totalGuesses > 0
            ? ((data['correctGuesses'] as int? ?? 0) / totalGuesses) * 100
            : 0.0;
        entries.add(LeaderboardEntry(
          userId: snap.docs[i].id,
          name: data['name'] as String? ?? 'Unknown',
          score: data['score'] as int? ?? 0,
          rank: i + 1,
          totalScans: data['totalScans'] as int? ?? 0,
          correctGuesses: data['correctGuesses'] as int? ?? 0,
          wrongGuesses: data['wrongGuesses'] as int? ?? 0,
          accuracy: accuracy,
        ));
      }
      return entries;
    });
  }

  // ─── All Participants ──────────────────────────────────

  Stream<List<UserProfile>> getAllParticipants() {
    return _users.orderBy('createdAt', descending: true).snapshots().map(
        (snap) => snap.docs
            .map((d) =>
                UserProfile.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  // ─── Event Stats ───────────────────────────────────────

  Stream<Map<String, dynamic>> getEventStats() {
    return _users.snapshots().asyncMap((usersSnap) async {
      final scansSnap = await _scans.count().get();
      final answersSnap = await _answers.count().get();

      int totalScore = 0;
      int totalCorrect = 0;
      int totalWrong = 0;
      for (final doc in usersSnap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalScore += data['score'] as int? ?? 0;
        totalCorrect += data['correctGuesses'] as int? ?? 0;
        totalWrong += data['wrongGuesses'] as int? ?? 0;
      }

      final totalParticipants = usersSnap.docs.length;
      final totalGuesses = totalCorrect + totalWrong;

      return {
        'totalParticipants': totalParticipants,
        'totalScans': scansSnap.count ?? 0,
        'totalAnswers': answersSnap.count ?? 0,
        'averageScore': totalParticipants > 0
            ? (totalScore / totalParticipants).toStringAsFixed(1)
            : '0',
        'averageAccuracy': totalGuesses > 0
            ? '${((totalCorrect / totalGuesses) * 100).toStringAsFixed(1)}%'
            : '0%',
      };
    });
  }
}
