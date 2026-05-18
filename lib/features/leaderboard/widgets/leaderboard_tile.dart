import 'package:flutter/material.dart';
import 'package:networking_game/core/theme/app_colors.dart';
import 'package:networking_game/core/constants/app_constants.dart';
import 'package:networking_game/models/leaderboard_entry.dart';

class LeaderboardTile extends StatefulWidget {
  final LeaderboardEntry entry;
  final int animationIndex;

  const LeaderboardTile({
    super.key,
    required this.entry,
    this.animationIndex = 0,
  });

  @override
  State<LeaderboardTile> createState() => _LeaderboardTileState();
}

class _LeaderboardTileState extends State<LeaderboardTile>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.animationIndex * 60), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _rankColor {
    switch (widget.entry.rank) {
      case 1:
        return AppColors.gold;
      case 2:
        return AppColors.silver;
      case 3:
        return AppColors.bronze;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final isTop3 = entry.rank <= 3;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _isHovered
                  ? Colors.white.withValues(alpha: 0.06)
                  : isTop3
                      ? _rankColor.withValues(alpha: 0.08)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isTop3
                  ? Border.all(color: _rankColor.withValues(alpha: 0.2))
                  : _isHovered
                      ? Border.all(
                          color: Colors.white.withValues(alpha: 0.1))
                      : null,
            ),
            child: Row(
              children: [
                // Rank
                SizedBox(
                  width: 40,
                  child: Text(
                    '#${entry.rank}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _rankColor,
                      fontSize: isTop3 ? 18 : 14,
                    ),
                  ),
                ),

                // Avatar
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: isTop3
                        ? [
                            BoxShadow(
                              color: _rankColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      entry.name.isNotEmpty
                          ? entry.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name + tier
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${AppConstants.getRankEmoji(entry.tier)} ${entry.tier}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Score
                SizedBox(
                  width: 60,
                  child: Text(
                    '${entry.score}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isTop3 ? _rankColor : AppColors.textPrimary,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Accuracy
                SizedBox(
                  width: 60,
                  child: Column(
                    children: [
                      Text(
                        '${entry.accuracy.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: entry.accuracy / 100,
                          backgroundColor:
                              AppColors.textSecondary.withValues(alpha: 0.15),
                          valueColor:
                              const AlwaysStoppedAnimation(AppColors.accentGreen),
                          minHeight: 3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Scans
                SizedBox(
                  width: 40,
                  child: Text(
                    '${entry.totalScans}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Trend
                SizedBox(
                  width: 32,
                  child: _buildTrend(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrend() {
    final change = widget.entry.rankChange;
    if (change == null || change == 0) {
      return const Icon(Icons.remove, color: AppColors.textSecondary, size: 16);
    }
    return Icon(
      change > 0 ? Icons.arrow_upward : Icons.arrow_downward,
      color: change > 0 ? AppColors.accentGreen : AppColors.errorRed,
      size: 16,
    );
  }
}
