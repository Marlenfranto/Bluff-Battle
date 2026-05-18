import 'package:flutter/material.dart';
import 'package:networking_game/core/theme/app_colors.dart';
import 'package:networking_game/core/widgets/glassmorphism_card.dart';
import 'package:networking_game/models/leaderboard_entry.dart';

class PodiumWidget extends StatelessWidget {
  final List<LeaderboardEntry> topPlayers;

  const PodiumWidget({super.key, required this.topPlayers});

  @override
  Widget build(BuildContext context) {
    if (topPlayers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.emoji_events_outlined,
                  size: 48,
                  color: AppColors.textSecondary.withValues(alpha: 0.3)),
              const SizedBox(height: 12),
              const Text('No players yet',
                  style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (topPlayers.length > 1)
            Expanded(
                child: _PodiumColumn(entry: topPlayers[1], place: 2))
          else
            const Expanded(child: SizedBox()),
          const SizedBox(width: 10),
          Expanded(child: _PodiumColumn(entry: topPlayers[0], place: 1)),
          const SizedBox(width: 10),
          if (topPlayers.length > 2)
            Expanded(
                child: _PodiumColumn(entry: topPlayers[2], place: 3))
          else
            const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}

class _PodiumColumn extends StatefulWidget {
  final LeaderboardEntry entry;
  final int place;

  const _PodiumColumn({required this.entry, required this.place});

  @override
  State<_PodiumColumn> createState() => _PodiumColumnState();
}

class _PodiumColumnState extends State<_PodiumColumn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnim = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // Stagger: 1st place animates first
    final delay = widget.place == 1
        ? 0
        : widget.place == 2
            ? 200
            : 400;
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _medalColor {
    switch (widget.place) {
      case 1:
        return AppColors.gold;
      case 2:
        return AppColors.silver;
      default:
        return AppColors.bronze;
    }
  }

  double get _pedestalHeight {
    switch (widget.place) {
      case 1:
        return 80;
      case 2:
        return 60;
      default:
        return 44;
    }
  }

  String get _medal {
    switch (widget.place) {
      case 1:
        return '👑';
      case 2:
        return '🥈';
      default:
        return '🥉';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFirst = widget.place == 1;
    final avatarSize = isFirst ? 64.0 : 48.0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _slideAnim.value),
        child: Opacity(opacity: _fadeAnim.value, child: child),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_medal, style: TextStyle(fontSize: isFirst ? 32 : 24)),
          const SizedBox(height: 8),

          // Avatar
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              border: Border.all(color: _medalColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: _medalColor.withValues(alpha: isFirst ? 0.5 : 0.3),
                  blurRadius: isFirst ? 20 : 12,
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.entry.name.isNotEmpty
                    ? widget.entry.name[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: isFirst ? 24 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          Text(
            widget.entry.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),

          Text(
            '${widget.entry.score} pts',
            style: TextStyle(
              color: _medalColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),

          // Pedestal
          GlassmorphismCard(
            padding: EdgeInsets.zero,
            borderRadius: 8,
            color: _medalColor,
            opacity: 0.2,
            child: Container(
              width: double.infinity,
              height: _pedestalHeight,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: _medalColor.withValues(alpha: 0.5), width: 2),
                ),
              ),
              child: Center(
                child: Text(
                  '#${widget.place}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _medalColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
