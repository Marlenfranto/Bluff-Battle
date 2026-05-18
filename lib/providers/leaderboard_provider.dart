import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:networking_game/models/leaderboard_entry.dart';
import 'package:networking_game/providers/auth_provider.dart';
import 'package:networking_game/providers/user_provider.dart';

final leaderboardProvider = StreamProvider<List<LeaderboardEntry>>((ref) {
  final isAuth = ref.watch(isAuthenticatedProvider);
  if (!isAuth) return Stream.value([]);
  return ref.watch(firestoreServiceProvider).getLeaderboard();
});

final eventStatsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final isAuth = ref.watch(isAuthenticatedProvider);
  if (!isAuth) {
    return Stream.value({
      'totalParticipants': 0,
      'totalScans': 0,
      'totalAnswers': 0,
      'averageScore': '0',
      'averageAccuracy': '0%',
    });
  }
  return ref.watch(firestoreServiceProvider).getEventStats();
});

final topPlayersProvider = Provider<List<LeaderboardEntry>>((ref) {
  final leaderboard = ref.watch(leaderboardProvider).valueOrNull ?? [];
  return leaderboard.take(3).toList();
});
