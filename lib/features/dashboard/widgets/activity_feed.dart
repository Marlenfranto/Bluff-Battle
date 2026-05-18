import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:networking_game/core/theme/app_colors.dart';
import 'package:networking_game/core/widgets/glassmorphism_card.dart';
import 'package:networking_game/models/leaderboard_entry.dart';
import 'package:networking_game/providers/leaderboard_provider.dart';

class ActivityFeed extends ConsumerWidget {
  const ActivityFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = ref.watch(leaderboardProvider).valueOrNull ?? [];
    final activities = _generateActivities(leaderboard);

    return GlassmorphismCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.accentOrange.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(Icons.bolt_rounded,
                    color: AppColors.accentOrange, size: 16),
              ),
              const SizedBox(width: 10),
              const Text(
                'Live Activity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accentGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PulsingDot(),
                    SizedBox(width: 4),
                    Text(
                      'Live',
                      style: TextStyle(
                        color: AppColors.accentGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (activities.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.hourglass_empty_rounded,
                        color: AppColors.textSecondary.withValues(alpha: 0.4),
                        size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'Waiting for activity...',
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...activities
                .take(10)
                .toList()
                .asMap()
                .entries
                .map((e) => _ActivityItem(
                      activity: e.value,
                      index: e.key,
                    )),
        ],
      ),
    );
  }

  List<_Activity> _generateActivities(List<LeaderboardEntry> entries) {
    final activities = <_Activity>[];
    for (final entry in entries) {
      if (entry.totalScans > 0) {
        activities.add(_Activity(
          playerName: entry.name,
          action:
              'scored ${entry.score} pts with ${entry.correctGuesses} correct',
          icon: Icons.star_rounded,
          color: AppColors.accentOrange,
        ));
      }
      if (entry.totalScans >= 5) {
        activities.add(_Activity(
          playerName: entry.name,
          action: 'scanned ${entry.totalScans} players',
          icon: Icons.qr_code_scanner_rounded,
          color: AppColors.electricBlue,
        ));
      }
    }
    return activities;
  }
}

class _Activity {
  final String playerName;
  final String action;
  final IconData icon;
  final Color color;

  const _Activity({
    required this.playerName,
    required this.action,
    required this.icon,
    required this.color,
  });
}

class _ActivityItem extends StatefulWidget {
  final _Activity activity;
  final int index;

  const _ActivityItem({required this.activity, required this.index});

  @override
  State<_ActivityItem> createState() => _ActivityItemState();
}

class _ActivityItemState extends State<_ActivityItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.05, 0),
          end: Offset.zero,
        ).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic)),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _isHovered
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: widget.activity.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.activity.color.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Icon(widget.activity.icon,
                      color: widget.activity.color, size: 15),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                      children: [
                        TextSpan(
                          text: widget.activity.playerName,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: ' ${widget.activity.action}'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
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
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.accentGreen.withValues(
              alpha: 0.5 + (_controller.value * 0.5),
            ),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
