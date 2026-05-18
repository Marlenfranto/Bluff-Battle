import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:networking_game/core/theme/app_colors.dart';
import 'package:networking_game/core/widgets/glassmorphism_card.dart';
import 'package:networking_game/models/leaderboard_entry.dart';

class ScoreDistributionChart extends StatelessWidget {
  final List<LeaderboardEntry> entries;

  const ScoreDistributionChart({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final ranges = {'0-5': 0, '6-10': 0, '11-20': 0, '21+': 0};
    for (final e in entries) {
      if (e.score <= 5) {
        ranges['0-5'] = ranges['0-5']! + 1;
      } else if (e.score <= 10) {
        ranges['6-10'] = ranges['6-10']! + 1;
      } else if (e.score <= 20) {
        ranges['11-20'] = ranges['11-20']! + 1;
      } else {
        ranges['21+'] = ranges['21+']! + 1;
      }
    }

    final colors = [
      AppColors.electricBlue,
      AppColors.primaryPurple,
      AppColors.neonPink,
      AppColors.accentOrange,
    ];

    final maxY =
        (ranges.values.reduce((a, b) => a > b ? a : b) + 2).toDouble();

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
                  color: AppColors.electricBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.electricBlue.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(Icons.bar_chart_rounded,
                    color: AppColors.electricBlue, size: 16),
              ),
              const SizedBox(width: 10),
              const Text(
                'Score Distribution',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final label = ranges.keys.toList()[group.x.toInt()];
                      return BarTooltipItem(
                        '$label\n${rod.toY.toInt()} players',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
                barGroups:
                    ranges.entries.toList().asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.value.toDouble(),
                        gradient: LinearGradient(
                          colors: [
                            colors[e.key],
                            colors[e.key].withValues(alpha: 0.5)
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 28,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: Colors.white.withValues(alpha: 0.03),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final labels = ranges.keys.toList();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            labels[value.toInt()],
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
              ),
              duration: const Duration(milliseconds: 600),
            ),
          ),
        ],
      ),
    );
  }
}

class RankDistributionChart extends StatelessWidget {
  final List<LeaderboardEntry> entries;

  const RankDistributionChart({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final ranks = <String, int>{
      'Beginner': 0,
      'Detective': 0,
      'Investigator': 0,
      'Mastermind': 0,
    };
    for (final e in entries) {
      ranks[e.tier] = (ranks[e.tier] ?? 0) + 1;
    }

    final colors = [
      AppColors.textSecondary,
      AppColors.electricBlue,
      AppColors.primaryPurple,
      AppColors.accentOrange,
    ];

    final total = entries.length.clamp(1, double.infinity).toDouble();

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
                  color: AppColors.primaryPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primaryPurple.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(Icons.pie_chart_rounded,
                    color: AppColors.primaryPurple, size: 16),
              ),
              const SizedBox(width: 10),
              const Text(
                'Rank Distribution',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 32,
                      sections: ranks.entries
                          .toList()
                          .asMap()
                          .entries
                          .map((e) {
                        final pct = (e.value.value / total) * 100;
                        return PieChartSectionData(
                          value: e.value.value.toDouble(),
                          title:
                              pct > 5 ? '${pct.toStringAsFixed(0)}%' : '',
                          color: colors[e.key],
                          radius: 44,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          borderSide: BorderSide(
                            color: colors[e.key].withValues(alpha: 0.5),
                            width: 1,
                          ),
                        );
                      }).toList(),
                    ),
                    duration: const Duration(milliseconds: 600),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: ranks.entries
                      .toList()
                      .asMap()
                      .entries
                      .map((e) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: colors[e.key],
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${e.value.key} (${e.value.value})',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
