import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:networking_game/app.dart';
import 'package:networking_game/firebase_options.dart';

/// Global auth future — started in main(), awaited in splash screen.
late final Future<User?> preWarmAuthFuture;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GoogleFonts.config.allowRuntimeFetching = true;

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Start anonymous auth immediately (before first frame)
  preWarmAuthFuture = _preWarmAuth();

  runApp(
    const ProviderScope(
      child: NetworkingGameApp(),
    ),
  );
}

Future<User?> _preWarmAuth() async {
  try {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser != null) return auth.currentUser;

    // Wait briefly for session restore
    final user = await auth.authStateChanges().first.timeout(
      const Duration(seconds: 2),
      onTimeout: () => null,
    );
    if (user != null) return user;

    // No existing session — sign in anonymously
    final result = await auth.signInAnonymously();
    return result.user;
  } catch (_) {
    return null;
  }
}
