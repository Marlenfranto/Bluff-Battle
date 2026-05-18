import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:networking_game/core/constants/app_constants.dart';
import 'package:networking_game/models/user_profile.dart';
import 'package:networking_game/models/scan_record.dart';
import 'package:networking_game/models/game_answer.dart';
import 'package:networking_game/providers/auth_provider.dart';
import 'package:networking_game/providers/user_provider.dart';
import 'package:uuid/uuid.dart';

class GameState {
  final bool isLoading;
  final UserProfile? targetProfile;
  final List<MapEntry<String, bool>> shuffledStatements;
  final int? selectedIndex;
  final bool hasAnswered;
  final bool? isCorrect;
  final int pointsAwarded;
  final String? error;
  final bool alreadyScanned;

  const GameState({
    this.isLoading = false,
    this.targetProfile,
    this.shuffledStatements = const [],
    this.selectedIndex,
    this.hasAnswered = false,
    this.isCorrect,
    this.pointsAwarded = 0,
    this.error,
    this.alreadyScanned = false,
  });

  GameState copyWith({
    bool? isLoading,
    UserProfile? targetProfile,
    List<MapEntry<String, bool>>? shuffledStatements,
    int? selectedIndex,
    bool? hasAnswered,
    bool? isCorrect,
    int? pointsAwarded,
    String? error,
    bool? alreadyScanned,
  }) {
    return GameState(
      isLoading: isLoading ?? this.isLoading,
      targetProfile: targetProfile ?? this.targetProfile,
      shuffledStatements: shuffledStatements ?? this.shuffledStatements,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      hasAnswered: hasAnswered ?? this.hasAnswered,
      isCorrect: isCorrect ?? this.isCorrect,
      pointsAwarded: pointsAwarded ?? this.pointsAwarded,
      error: error,
      alreadyScanned: alreadyScanned ?? this.alreadyScanned,
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  final Ref _ref;

  GameNotifier(this._ref) : super(const GameState());

  Future<void> loadGame(String scannedUserId) async {
    state = const GameState(isLoading: true);

    try {
      final firestore = _ref.read(firestoreServiceProvider);
      final currentUserId = _ref.read(currentUserIdProvider);

      if (currentUserId == null) {
        state = const GameState(error: 'Not authenticated');
        return;
      }

      if (currentUserId == scannedUserId) {
        state = const GameState(error: 'You cannot scan yourself!');
        return;
      }

      // Check if already scanned
      final alreadyScanned =
          await firestore.checkIfScanned(currentUserId, scannedUserId);
      if (alreadyScanned) {
        state = const GameState(
          error: 'You have already scanned this person!',
          alreadyScanned: true,
        );
        return;
      }

      // Fetch target profile
      final profile = await firestore.getUserProfile(scannedUserId);
      if (profile == null) {
        state = const GameState(error: 'Player not found');
        return;
      }

      if (!profile.hasCompletedProfile) {
        state = const GameState(error: 'This player has not set up their profile yet');
        return;
      }

      final statements = _shuffleStatements(profile);

      state = GameState(
        targetProfile: profile,
        shuffledStatements: statements,
      );
    } catch (e) {
      state = GameState(error: 'Failed to load game: $e');
    }
  }

  List<MapEntry<String, bool>> _shuffleStatements(UserProfile profile) {
    final statements = [
      MapEntry(profile.truth1, false),
      MapEntry(profile.truth2, false),
      MapEntry(profile.lie, true),
    ];
    statements.shuffle();
    return statements;
  }

  void selectAnswer(int index) {
    if (state.hasAnswered) return;
    state = state.copyWith(selectedIndex: index);
  }

  Future<void> submitAnswer() async {
    if (state.selectedIndex == null || state.hasAnswered) return;

    final selectedIndex = state.selectedIndex!;
    final isLie = state.shuffledStatements[selectedIndex].value;
    final points = isLie ? AppConstants.correctPoints : AppConstants.wrongPoints;

    state = state.copyWith(isLoading: true);

    try {
      final firestore = _ref.read(firestoreServiceProvider);
      final currentUserId = _ref.read(currentUserIdProvider)!;
      final targetId = state.targetProfile!.id;
      const uuid = Uuid();

      debugPrint('[GAME] currentUserId=$currentUserId targetId=$targetId');

      // Record scan
      try {
        await firestore.recordScan(ScanRecord(
          id: uuid.v4(),
          scannerId: currentUserId,
          scannedId: targetId,
          answered: true,
          correct: isLie,
        ));
        debugPrint('[GAME] recordScan OK');
      } catch (e) {
        debugPrint('[GAME] recordScan FAILED: $e');
        rethrow;
      }

      // Record answer
      try {
        await firestore.recordAnswer(GameAnswer(
          id: uuid.v4(),
          guesserId: currentUserId,
          targetId: targetId,
          selectedStatement: state.shuffledStatements[selectedIndex].key,
          isCorrect: isLie,
          pointsAwarded: points,
        ));
        debugPrint('[GAME] recordAnswer OK');
      } catch (e) {
        debugPrint('[GAME] recordAnswer FAILED: $e');
        rethrow;
      }

      // Update score
      try {
        await firestore.updateScore(currentUserId, points, isLie);
        debugPrint('[GAME] updateScore OK');
      } catch (e) {
        debugPrint('[GAME] updateScore FAILED: $e');
        rethrow;
      }

      // Add connection
      try {
        await firestore.addConnection(currentUserId, targetId);
        debugPrint('[GAME] addConnection OK');
      } catch (e) {
        debugPrint('[GAME] addConnection FAILED: $e');
        rethrow;
      }

      state = state.copyWith(
        isLoading: false,
        hasAnswered: true,
        isCorrect: isLie,
        pointsAwarded: points,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to submit answer: $e',
      );
    }
  }

  void reset() {
    state = const GameState();
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier(ref);
});
