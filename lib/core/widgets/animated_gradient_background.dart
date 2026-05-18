import 'package:flutter/material.dart';
import 'package:networking_game/core/theme/app_colors.dart';

/// Lightweight gradient background.
/// Uses a static gradient by default for performance.
/// Set [animate] to true for the splash/special screens.
class AnimatedGradientBackground extends StatelessWidget {
  final Widget child;
  final bool animate;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    if (animate) {
      return _AnimatedVersion(child: child);
    }
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: child,
    );
  }
}

class _AnimatedVersion extends StatefulWidget {
  final Widget child;
  const _AnimatedVersion({required this.child});

  @override
  State<_AnimatedVersion> createState() => _AnimatedVersionState();
}

class _AnimatedVersionState extends State<_AnimatedVersion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _beginAlignment;
  late Animation<Alignment> _endAlignment;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);

    _beginAlignment = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: Tween(begin: Alignment.topLeft, end: Alignment.topRight),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Alignment.topRight, end: Alignment.bottomRight),
        weight: 1,
      ),
    ]).animate(_controller);

    _endAlignment = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: Tween(begin: Alignment.bottomRight, end: Alignment.bottomLeft),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Alignment.bottomLeft, end: Alignment.topLeft),
        weight: 1,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: _beginAlignment.value,
              end: _endAlignment.value,
              colors: const [
                AppColors.darkCharcoal,
                AppColors.darkSurface,
                Color(0xFF0F3460),
              ],
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
