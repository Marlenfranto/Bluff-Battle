import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:networking_game/core/theme/app_colors.dart';
import 'package:networking_game/core/constants/app_constants.dart';
import 'package:networking_game/core/widgets/glassmorphism_card.dart';
import 'package:networking_game/core/extensions/context_extensions.dart';
import 'package:networking_game/models/user_profile.dart';
import 'package:networking_game/providers/auth_provider.dart';
import 'package:networking_game/providers/user_provider.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

final _allParticipantsProvider = StreamProvider<List<UserProfile>>((ref) {
  final isAuth = ref.watch(isAuthenticatedProvider);
  if (!isAuth) return Stream.value([]);
  return ref.watch(firestoreServiceProvider).getAllParticipants();
});

class ParticipantTable extends ConsumerStatefulWidget {
  const ParticipantTable({super.key});

  @override
  ConsumerState<ParticipantTable> createState() => _ParticipantTableState();
}

class _ParticipantTableState extends ConsumerState<ParticipantTable> {
  String _search = '';
  int _sortColumnIndex = 3;
  bool _sortAscending = false;

  @override
  Widget build(BuildContext context) {
    final participantsAsync = ref.watch(_allParticipantsProvider);

    return Padding(
      padding: const EdgeInsets.all(28),
      child: participantsAsync.when(
        loading: () => _buildLoading(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (participants) {
          var filtered = participants.where((p) {
            if (_search.isEmpty) return true;
            final s = _search.toLowerCase();
            return p.name.toLowerCase().contains(s) ||
                (p.email?.toLowerCase().contains(s) ?? false);
          }).toList();

          filtered.sort((a, b) {
            int cmp;
            switch (_sortColumnIndex) {
              case 0:
                cmp = a.name.compareTo(b.name);
              case 1:
                cmp = (a.email ?? '').compareTo(b.email ?? '');
              case 3:
                cmp = a.score.compareTo(b.score);
              case 4:
                cmp = a.totalScans.compareTo(b.totalScans);
              default:
                cmp = a.name.compareTo(b.name);
            }
            return _sortAscending ? cmp : -cmp;
          });

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
                        color: AppColors.neonPink.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.neonPink.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(Icons.people_rounded,
                          color: AppColors.neonPink, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'All Participants',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${filtered.length}',
                        style: const TextStyle(
                          color: AppColors.primaryPurple,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 220,
                      height: 36,
                      child: TextField(
                        onChanged: (v) => setState(() => _search = v),
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search participants...',
                          prefixIcon:
                              const Icon(Icons.search, size: 18),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor:
                              AppColors.darkCharcoal.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: 'Export data',
                      child: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: const Icon(Icons.download_rounded,
                              color: AppColors.textSecondary, size: 16),
                        ),
                        onPressed: () =>
                            context.showSnackBar('Export coming soon'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minWidth: constraints.maxWidth),
                      child: DataTable(
                        sortColumnIndex: _sortColumnIndex,
                        sortAscending: _sortAscending,
                        headingRowHeight: 44,
                        dataRowMinHeight: 52,
                        dataRowMaxHeight: 52,
                        columnSpacing: 24,
                        headingTextStyle: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                        dataTextStyle: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                        ),
                        columns: [
                          DataColumn(
                            label: const Text('NAME'),
                            onSort: (i, asc) => setState(() {
                              _sortColumnIndex = i;
                              _sortAscending = asc;
                            }),
                          ),
                          DataColumn(
                            label: const Text('EMAIL'),
                            onSort: (i, asc) => setState(() {
                              _sortColumnIndex = i;
                              _sortAscending = asc;
                            }),
                          ),
                          const DataColumn(label: Text('RANK')),
                          DataColumn(
                            label: const Text('SCORE'),
                            numeric: true,
                            onSort: (i, asc) => setState(() {
                              _sortColumnIndex = i;
                              _sortAscending = asc;
                            }),
                          ),
                          DataColumn(
                            label: const Text('SCANS'),
                            numeric: true,
                            onSort: (i, asc) => setState(() {
                              _sortColumnIndex = i;
                              _sortAscending = asc;
                            }),
                          ),
                          const DataColumn(label: Text('JOINED')),
                        ],
                        rows: filtered.asMap().entries.map((e) {
                          final p = e.value;
                          final isEven = e.key % 2 == 0;
                          return DataRow(
                            color: WidgetStateProperty.resolveWith(
                              (states) {
                                if (states
                                    .contains(WidgetState.hovered)) {
                                  return Colors.white
                                      .withValues(alpha: 0.06);
                                }
                                return isEven
                                    ? Colors.white
                                        .withValues(alpha: 0.02)
                                    : Colors.transparent;
                              },
                            ),
                            cells: [
                              DataCell(Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: const BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        p.name.isNotEmpty
                                            ? p.name[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(p.name),
                                ],
                              )),
                              DataCell(Text(p.email ?? '-',
                                  style: TextStyle(
                                      color: AppColors.textSecondary))),
                              DataCell(Text(
                                '${AppConstants.getRankEmoji(p.rank)} ${p.rank}',
                              )),
                              DataCell(Text('${p.score}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600))),
                              DataCell(Text('${p.totalScans}')),
                              DataCell(Text(
                                DateFormat.MMMd().format(p.createdAt),
                                style: TextStyle(
                                    color: AppColors.textSecondary),
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoading() {
    return Shimmer.fromColors(
      baseColor: AppColors.darkCard,
      highlightColor: AppColors.darkSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            6,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
