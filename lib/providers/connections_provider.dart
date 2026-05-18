import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:networking_game/models/user_profile.dart';
import 'package:networking_game/providers/auth_provider.dart';
import 'package:networking_game/providers/user_provider.dart';

final connectionsProvider = StreamProvider<List<UserProfile>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value([]);
  return ref.watch(firestoreServiceProvider).getConnections(userId);
});

final connectionSearchProvider = StateProvider<String>((ref) => '');

final connectionSortProvider = StateProvider<ConnectionSort>(
    (ref) => ConnectionSort.recent);

enum ConnectionSort { recent, name }

final filteredConnectionsProvider = Provider<List<UserProfile>>((ref) {
  final connections = ref.watch(connectionsProvider).valueOrNull ?? [];
  final search = ref.watch(connectionSearchProvider).toLowerCase();
  final sort = ref.watch(connectionSortProvider);

  var filtered = connections.where((c) {
    if (search.isEmpty) return true;
    return c.name.toLowerCase().contains(search) ||
        (c.email?.toLowerCase().contains(search) ?? false) ||
        (c.phone?.contains(search) ?? false);
  }).toList();

  switch (sort) {
    case ConnectionSort.name:
      filtered.sort((a, b) => a.name.compareTo(b.name));
    case ConnectionSort.recent:
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  return filtered;
});
