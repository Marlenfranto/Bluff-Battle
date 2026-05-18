import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:networking_game/core/theme/app_colors.dart';
import 'package:networking_game/core/widgets/glassmorphism_card.dart';
import 'package:networking_game/features/leaderboard/widgets/leaderboard_tile.dart';
import 'package:networking_game/features/leaderboard/widgets/podium_widget.dart';
import 'package:networking_game/providers/leaderboard_provider.dart';
import 'package:shimmer/shimmer.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return leaderboardAsync.when(
      loading: () => _buildLoading(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (entries) {
        final topPlayers = entries.take(3).toList();
        final restPlayers =
            entries.length > 3 ? entries.sublist(3) : <dynamic>[];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.accentOrange.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(Icons.emoji_events_rounded,
                        color: AppColors.accentOrange, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppColors.primaryGradient.createShader(bounds),
                        child: const Text(
                          'Leaderboard',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        '${entries.length} players competing',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Podium
              if (topPlayers.isNotEmpty) ...[
                PodiumWidget(topPlayers: topPlayers),
                const SizedBox(height: 32),
              ],

              // Table
              if (restPlayers.isNotEmpty)
                GlassmorphismCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Column headers
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 12, left: 16, right: 16),
                        child: Row(
                          children: const [
                            SizedBox(
                                width: 40,
                                child: Text('Rank',
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600))),
                            SizedBox(width: 48),
                            Expanded(
                                flex: 3,
                                child: Text('Player',
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600))),
                            SizedBox(
                                width: 60,
                                child: Text('Score',
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center)),
                            SizedBox(
                                width: 60,
                                child: Text('Acc.',
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center)),
                            SizedBox(width: 16),
                            SizedBox(
                                width: 40,
                                child: Text('Scans',
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center)),
                            SizedBox(width: 32),
                          ],
                        ),
                      ),
                      Divider(
                          color: AppColors.textSecondary.withValues(alpha: 0.15),
                          height: 1),
                      const SizedBox(height: 8),
                      ...restPlayers
                          .asMap()
                          .entries
                          .map((e) => LeaderboardTile(
                                entry: e.value,
                                animationIndex: e.key,
                              )),
                    ],
                  ),
                ),

              if (entries.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(64),
                    child: Column(
                      children: [
                        Icon(Icons.emoji_events_outlined,
                            size: 64,
                            color: AppColors.textSecondary
                                .withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        const Text('No players yet',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 18)),
                        const SizedBox(height: 8),
                        Text(
                          'Players will appear here once they start playing',
                          style: TextStyle(
                            color:
                                AppColors.textSecondary.withValues(alpha: 0.6),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoading() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Shimmer.fromColors(
        baseColor: AppColors.darkCard,
        highlightColor: AppColors.darkSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 200,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 20),
            ...List.generate(
              5,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
