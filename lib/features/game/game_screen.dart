import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:networking_game/core/theme/app_colors.dart';
import 'package:networking_game/core/widgets/animated_button.dart';
import 'package:networking_game/core/widgets/animated_gradient_background.dart';
import 'package:networking_game/core/widgets/glassmorphism_card.dart';
import 'package:networking_game/core/widgets/loading_overlay.dart';
import 'package:networking_game/core/extensions/context_extensions.dart';
import 'package:networking_game/features/game/widgets/statement_card.dart';
import 'package:networking_game/providers/game_provider.dart';

class GameScreen extends ConsumerStatefulWidget {
  final String scannedUserId;

  const GameScreen({super.key, required this.scannedUserId});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _resultAnimController;
  late Animation<double> _resultScaleAnim;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _resultAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _resultScaleAnim = CurvedAnimation(
      parent: _resultAnimController,
      curve: Curves.elasticOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameProvider.notifier).loadGame(widget.scannedUserId);
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _resultAnimController.dispose();
    ref.read(gameProvider.notifier).reset();
    super.dispose();
  }

  void _onSubmit() async {
    await ref.read(gameProvider.notifier).submitAnswer();
    final state = ref.read(gameProvider);
    if (state.hasAnswered) {
      if (state.isCorrect == true) {
        _confettiController.play();
      }
      _resultAnimController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final isSmall = context.isSmallScreen;
    final pad = context.responsivePadding;

    return Scaffold(
      body: AnimatedGradientBackground(
        child: Stack(
          children: [
            LoadingOverlay(
              isLoading: gameState.isLoading,
              message: 'Loading game...',
              child: SafeArea(
                child: _buildContent(gameState, isSmall, pad),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: pi / 2,
                maxBlastForce: 5,
                minBlastForce: 2,
                emissionFrequency: 0.05,
                numberOfParticles: 20,
                gravity: 0.1,
                colors: const [
                  AppColors.primaryPurple,
                  AppColors.electricBlue,
                  AppColors.neonPink,
                  AppColors.accentGreen,
                  AppColors.accentOrange,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(GameState gameState, bool isSmall, double pad) {
    if (gameState.error != null) {
      return _buildError(gameState.error!, isSmall, pad);
    }

    if (gameState.targetProfile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final profile = gameState.targetProfile!;

    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(
        children: [
          // Back button
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary, size: 20),
              onPressed: () => context.pop(),
            ),
          ),
          SizedBox(height: isSmall ? 4 : 8),

          // Player avatar
          Container(
            width: isSmall ? 48 : 64,
            height: isSmall ? 48 : 64,
            decoration: const BoxDecoration(
              gradient: AppColors.accentGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: isSmall ? 20 : 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: isSmall ? 8 : 12),
          Text(
            profile.name,
            style: TextStyle(
              fontSize: isSmall ? 18 : 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isSmall ? 16 : 24),

          // Question
          FittedBox(
            fit: BoxFit.scaleDown,
            child: ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.primaryGradient.createShader(bounds),
              child: Text(
                'Which one is the LIE?',
                style: TextStyle(
                  fontSize: isSmall ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: isSmall ? 16 : 24),

          // Statement cards
          ...List.generate(gameState.shuffledStatements.length, (index) {
            final entry = gameState.shuffledStatements[index];
            return Padding(
              padding: EdgeInsets.only(bottom: isSmall ? 8 : 12),
              child: StatementCard(
                index: index,
                statement: entry.key,
                isSelected: gameState.selectedIndex == index,
                isRevealed: gameState.hasAnswered,
                isLie: entry.value,
                isSmall: isSmall,
                onTap: gameState.hasAnswered
                    ? null
                    : () => ref.read(gameProvider.notifier).selectAnswer(index),
              ),
            );
          }),

          SizedBox(height: isSmall ? 12 : 16),

          // Result or submit button
          if (gameState.hasAnswered)
            ScaleTransition(
              scale: _resultScaleAnim,
              child: _buildResult(gameState, isSmall),
            )
          else if (gameState.selectedIndex != null)
            AnimatedButton(
              onPressed: _onSubmit,
              width: double.infinity,
              gradient: AppColors.accentGradient,
              padding: EdgeInsets.symmetric(vertical: isSmall ? 12 : 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text('Lock In Answer', style: TextStyle(fontSize: isSmall ? 14 : 16)),
                ],
              ),
            ),

          SizedBox(height: isSmall ? 16 : 32),
        ],
      ),
    );
  }

  Widget _buildResult(GameState gameState, bool isSmall) {
    final isCorrect = gameState.isCorrect == true;
    return GlassmorphismCard(
      color: isCorrect ? AppColors.accentGreen : AppColors.errorRed,
      opacity: 0.15,
      border: Border.all(
        color: isCorrect ? AppColors.accentGreen : AppColors.errorRed,
        width: 2,
      ),
      padding: EdgeInsets.all(isSmall ? 16 : 20),
      child: Column(
        children: [
          Icon(
            isCorrect ? Icons.celebration : Icons.sentiment_dissatisfied,
            color: isCorrect ? AppColors.accentGreen : AppColors.errorRed,
            size: isSmall ? 36 : 48,
          ),
          SizedBox(height: isSmall ? 8 : 12),
          Text(
            isCorrect ? 'Correct!' : 'Nice try!',
            style: TextStyle(
              fontSize: isSmall ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: isCorrect ? AppColors.accentGreen : AppColors.errorRed,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${gameState.pointsAwarded > 0 ? '+' : ''}${gameState.pointsAwarded} point',
            style: TextStyle(
              fontSize: isSmall ? 15 : 18,
              color: isCorrect ? AppColors.accentGreen : AppColors.errorRed,
            ),
          ),
          SizedBox(height: isSmall ? 12 : 16),
          AnimatedButton(
            onPressed: () => context.pop(),
            gradient: isCorrect
                ? AppColors.successGradient
                : AppColors.primaryGradient,
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 16 : 24,
              vertical: isSmall ? 10 : 12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.people, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text('Connection Added!', style: TextStyle(fontSize: isSmall ? 13 : 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error, bool isSmall, double pad) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: GlassmorphismCard(
          padding: EdgeInsets.all(isSmall ? 20 : 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: AppColors.errorRed, size: isSmall ? 36 : 48),
              SizedBox(height: isSmall ? 12 : 16),
              Text(
                error,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: isSmall ? 14 : 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isSmall ? 16 : 24),
              AnimatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
