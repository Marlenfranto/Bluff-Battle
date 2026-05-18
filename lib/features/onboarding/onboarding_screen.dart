import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:networking_game/core/theme/app_colors.dart';
import 'package:networking_game/core/widgets/animated_button.dart';
import 'package:networking_game/core/widgets/animated_gradient_background.dart';
import 'package:networking_game/core/extensions/context_extensions.dart';
import 'package:networking_game/providers/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pageData = [
    _PageData(
      icon: Icons.person_add_rounded,
      title: 'Create Your Profile',
      description:
          'Set up your name, LinkedIn, and write 2 truths and 1 lie about yourself. Make them tricky!',
      gradientColors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
    ),
    _PageData(
      icon: Icons.qr_code_scanner_rounded,
      title: 'Scan & Guess',
      description:
          'Scan other players\' QR codes and try to figure out which statement is the lie.',
      gradientColors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
    ),
    _PageData(
      icon: Icons.emoji_events_rounded,
      title: 'Climb the Ranks',
      description:
          'Earn points for correct guesses, climb the leaderboard, and become the Mastermind!',
      gradientColors: [Color(0xFFEC4899), Color(0xFFDB2777)],
    ),
  ];

  void _onNext() async {
    if (_currentPage < _pageData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      final authService = ref.read(authServiceProvider);
      if (!authService.isSignedIn) {
        await authService.signInAnonymously();
      }
      if (mounted) context.go('/profile-setup');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = context.isSmallScreen;
    final pad = context.responsivePadding;

    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(right: pad),
                  child: TextButton(
                    onPressed: () async {
                      final authService = ref.read(authServiceProvider);
                      if (!authService.isSignedIn) {
                        await authService.signInAnonymously();
                      }
                      if (mounted) context.go('/profile-setup');
                    },
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _pageData.length,
                  itemBuilder: (context, index) {
                    final data = _pageData[index];
                    return _OnboardingPage(data: data, isSmall: isSmall);
                  },
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(vertical: isSmall ? 16 : 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pageData.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _currentPage == index
                            ? AppColors.primaryPurple
                            : AppColors.textSecondary.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(pad, 0, pad, isSmall ? 12 : 16),
                child: AnimatedButton(
                  onPressed: _onNext,
                  width: double.infinity,
                  child: Text(
                    _currentPage == _pageData.length - 1
                        ? 'Get Started'
                        : 'Next',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: isSmall ? 8 : 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageData {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradientColors;

  const _PageData({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradientColors,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _PageData data;
  final bool isSmall;

  const _OnboardingPage({required this.data, required this.isSmall});

  @override
  Widget build(BuildContext context) {
    final iconContainerSize = isSmall ? 88.0 : 120.0;
    final iconSize = isSmall ? 40.0 : 56.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 20 : 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: iconContainerSize,
            height: iconContainerSize,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: data.gradientColors),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: data.gradientColors.first.withValues(alpha: 0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(data.icon, size: iconSize, color: Colors.white),
          ),
          SizedBox(height: isSmall ? 32 : 48),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              data.title,
              style: TextStyle(
                fontSize: isSmall ? 22 : 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: isSmall ? 12 : 16),
          Text(
            data.description,
            style: TextStyle(
              fontSize: isSmall ? 14 : 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
