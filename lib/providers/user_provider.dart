import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:networking_game/models/user_profile.dart';
import 'package:networking_game/providers/auth_provider.dart';
import 'package:networking_game/services/firestore_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final currentUserProfileProvider = StreamProvider<UserProfile?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value(null);
  return ref.watch(firestoreServiceProvider).userProfileStream(userId);
});

final userProfileFamilyProvider =
    StreamProvider.family<UserProfile?, String>((ref, userId) {
  return ref.watch(firestoreServiceProvider).userProfileStream(userId);
});

final hasCompletedProfileProvider = Provider<bool>((ref) {
  final profile = ref.watch(currentUserProfileProvider).valueOrNull;
  return profile?.hasCompletedProfile ?? false;
});
