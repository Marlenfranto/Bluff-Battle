import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:networking_game/core/theme/app_colors.dart';
import 'package:networking_game/core/widgets/stat_card.dart';
import 'package:networking_game/core/widgets/glassmorphism_card.dart';
import 'package:networking_game/features/dashboard/widgets/activity_feed.dart';
import 'package:networking_game/features/dashboard/widgets/stats_chart.dart';
import 'package:networking_game/features/leaderboard/widgets/podium_widget.dart';
import 'package:networking_game/providers/leaderboard_provider.dart';
import 'package:shimmer/shimmer.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(eventStatsProvider);
    final topPlayers = ref.watch(topPlayersProvider);
    final leaderboard = ref.watch(leaderboardProvider).valueOrNull ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Image.asset(
                'assets/images/bingo.png',
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.primaryGradient.createShader(bounds),
                    child: const Text(
                      'Event Dashboard',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Real-time event monitoring',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Live indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.accentGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.accentGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Live',
                      style: TextStyle(
                        color: AppColors.accentGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Stats row
          statsAsync.when(
            loading: () => _buildStatsLoading(),
            error: (e, _) => Text('Error: $e'),
            data: (stats) {
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 240,
                    child: StatCard(
                      icon: Icons.people,
                      label: 'Total Participants',
                      value: '${stats['totalParticipants']}',
                      iconColor: AppColors.electricBlue,
                    ),
                  ),
                  SizedBox(
                    width: 240,
                    child: StatCard(
                      icon: Icons.qr_code_scanner,
                      label: 'Total Scans',
                      value: '${stats['totalScans']}',
                      iconColor: AppColors.neonPink,
                    ),
                  ),
                  SizedBox(
                    width: 240,
                    child: StatCard(
                      icon: Icons.star_rounded,
                      label: 'Average Score',
                      value: '${stats['averageScore']}',
                      iconColor: AppColors.accentOrange,
                    ),
                  ),
                  SizedBox(
                    width: 240,
                    child: StatCard(
                      icon: Icons.track_changes,
                      label: 'Avg. Accuracy',
                      value: '${stats['averageAccuracy']}',
                      iconColor: AppColors.accentGreen,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),

          // Podium + Chart
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 700) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GlassmorphismCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeader(Icons.emoji_events_rounded,
                                'Top Players', AppColors.accentOrange),
                            const SizedBox(height: 20),
                            PodiumWidget(topPlayers: topPlayers),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ScoreDistributionChart(entries: leaderboard),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  GlassmorphismCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _sectionHeader(Icons.emoji_events_rounded,
                            'Top Players', AppColors.accentOrange),
                        const SizedBox(height: 20),
                        PodiumWidget(topPlayers: topPlayers),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ScoreDistributionChart(entries: leaderboard),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Activity + Rank chart
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 700) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(child: ActivityFeed()),
                    const SizedBox(width: 20),
                    Expanded(
                        child: RankDistributionChart(entries: leaderboard)),
                  ],
                );
              }
              return Column(
                children: [
                  const ActivityFeed(),
                  const SizedBox(height: 20),
                  RankDistributionChart(entries: leaderboard),
                ],
              );
            },
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsLoading() {
    return Shimmer.fromColors(
      baseColor: AppColors.darkCard,
      highlightColor: AppColors.darkSurface,
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: List.generate(
          4,
          (_) => Container(
            width: 240,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
