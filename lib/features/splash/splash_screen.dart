import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:networking_game/core/constants/app_constants.dart';
import 'package:networking_game/core/theme/app_colors.dart';
import 'package:networking_game/core/extensions/context_extensions.dart';
import 'package:networking_game/main.dart';
import 'package:networking_game/providers/auth_provider.dart';
import 'package:networking_game/providers/user_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Start navigation immediately — don't wait for animation
    _navigate();
  }

  Future<void> _navigate() async {
    // Wait for pre-warmed auth (started in main.dart, already running)
    await preWarmAuthFuture;

    // Ensure minimum 800ms splash so it doesn't flash
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted || _navigating) return;
    _navigating = true;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= AppConstants.mobileBreakpoint;

    // Desktop → dashboard immediately
    if (isDesktop) {
      context.go('/dashboard');
      return;
    }

    // Mobile → check profile
    final authService = ref.read(authServiceProvider);
    final userId = authService.currentUserId;

    if (userId != null) {
      try {
        final firestore = ref.read(firestoreServiceProvider);
        final profile = await firestore.getUserProfile(userId);
        if (!mounted) return;

        if (profile != null && profile.hasCompletedProfile) {
          context.go('/home');
          return;
        }
      } catch (_) {}
    }

    if (mounted) context.go('/onboarding');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = context.isSmallScreen;
    final iconSize = isSmall ? 72.0 : 96.0;

    return Scaffold(
      backgroundColor: AppColors.darkCharcoal,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryPurple.withValues(alpha: 0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/bingo.png',
                        width: iconSize,
                        height: iconSize,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: isSmall ? 20 : 28),
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.primaryGradient.createShader(bounds),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Bluff Battle',
                          style: TextStyle(
                            fontSize: isSmall ? 26 : 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(AppColors.primaryPurple),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
