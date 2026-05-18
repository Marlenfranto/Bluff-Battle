import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  bool get isSignedIn => _auth.currentUser != null;

  String? get currentUserId => _auth.currentUser?.uid;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Waits for Firebase Auth to restore the persisted session on web.
  /// Returns the current user (or null if no session exists).
  Future<User?> waitForAuthReady() async {
    // If already signed in, return immediately
    if (_auth.currentUser != null) return _auth.currentUser;

    // Otherwise wait for the first auth state emission (session restore)
    final completer = Completer<User?>();
    final subscription = _auth.authStateChanges().listen((user) {
      if (!completer.isCompleted) {
        completer.complete(user);
      }
    });

    final user = await completer.future.timeout(
      const Duration(seconds: 2),
      onTimeout: () => null,
    );
    await subscription.cancel();
    return user;
  }

  Future<User> signInAnonymously() async {
    final result = await _auth.signInAnonymously();
    return result.user!;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
