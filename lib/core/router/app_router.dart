import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:networking_game/core/constants/app_constants.dart';
import 'package:networking_game/features/splash/splash_screen.dart';
import 'package:networking_game/features/onboarding/onboarding_screen.dart';
import 'package:networking_game/features/profile/profile_setup_screen.dart';
import 'package:networking_game/features/home/mobile_home_screen.dart';
import 'package:networking_game/features/home/desktop_home_screen.dart';
import 'package:networking_game/features/game/game_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final screenWidth = MediaQuery.sizeOf(context).width;
      final isDesktop = screenWidth >= AppConstants.mobileBreakpoint;
      final path = state.uri.path;

      // Desktop: redirect mobile-only routes to dashboard
      if (isDesktop) {
        const mobileOnlyRoutes = ['/onboarding', '/profile-setup', '/home'];
        if (mobileOnlyRoutes.contains(path)) {
          return '/dashboard';
        }
      }

      // Mobile: redirect dashboard to home
      if (!isDesktop && path == '/dashboard') {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      // Mobile-only routes
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MobileHomeScreen(),
      ),
      // Desktop route
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DesktopHomeScreen(),
      ),
      // Shared routes
      GoRoute(
        path: '/game/:scannedUserId',
        builder: (context, state) {
          final scannedUserId = state.pathParameters['scannedUserId']!;
          return GameScreen(scannedUserId: scannedUserId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});
