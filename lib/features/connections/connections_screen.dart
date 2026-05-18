import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:networking_game/core/theme/app_colors.dart';
import 'package:networking_game/core/widgets/animated_gradient_background.dart';
import 'package:networking_game/core/widgets/glassmorphism_card.dart';
import 'package:networking_game/core/extensions/context_extensions.dart';
import 'package:networking_game/features/connections/widgets/connection_card.dart';
import 'package:networking_game/providers/connections_provider.dart';

class ConnectionsScreen extends ConsumerWidget {
  const ConnectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connections = ref.watch(filteredConnectionsProvider);
    final search = ref.watch(connectionSearchProvider);
    final sort = ref.watch(connectionSortProvider);
    final isSmall = context.isSmallScreen;
    final pad = context.responsivePadding;

    return AnimatedGradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(pad, pad, pad, 8),
              child: Column(
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'My Connections',
                          style: TextStyle(
                            fontSize: isSmall ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GlassmorphismCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        borderRadius: 12,
                        child: Text(
                          '${connections.length}',
                          style: TextStyle(
                            color: AppColors.primaryPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: isSmall ? 13 : 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmall ? 8 : 12),

                  // Search
                  GlassmorphismCard(
                    padding: EdgeInsets.zero,
                    borderRadius: 12,
                    child: TextField(
                      onChanged: (v) =>
                          ref.read(connectionSearchProvider.notifier).state = v,
                      style: TextStyle(fontSize: isSmall ? 13 : 14),
                      decoration: InputDecoration(
                        hintText: 'Search connections...',
                        prefixIcon: const Icon(Icons.search,
                            color: AppColors.textSecondary, size: 20),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: isSmall ? 10 : 12),
                        suffixIcon: search.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear,
                                    color: AppColors.textSecondary, size: 18),
                                onPressed: () => ref
                                    .read(connectionSearchProvider.notifier)
                                    .state = '',
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Sort
                  Row(
                    children: [
                      _SortChip(
                        label: 'Recent',
                        isSelected: sort == ConnectionSort.recent,
                        isSmall: isSmall,
                        onTap: () => ref
                            .read(connectionSortProvider.notifier)
                            .state = ConnectionSort.recent,
                      ),
                      const SizedBox(width: 8),
                      _SortChip(
                        label: 'Name',
                        isSelected: sort == ConnectionSort.name,
                        isSmall: isSmall,
                        onTap: () => ref
                            .read(connectionSortProvider.notifier)
                            .state = ConnectionSort.name,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: connections.isEmpty
                  ? _buildEmptyState(isSmall)
                  : ListView.builder(
                      padding: EdgeInsets.all(pad),
                      itemCount: connections.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ConnectionCard(connection: connections[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isSmall) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline,
                size: isSmall ? 48 : 64,
                color: AppColors.textSecondary.withValues(alpha: 0.5)),
            SizedBox(height: isSmall ? 12 : 16),
            Text(
              'No connections yet',
              style: TextStyle(
                fontSize: isSmall ? 16 : 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan QR codes to start connecting!',
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.7),
                fontSize: isSmall ? 13 : 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isSmall;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.isSelected,
    required this.isSmall,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 12 : 16,
          vertical: isSmall ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryPurple.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryPurple
                : AppColors.textSecondary.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primaryPurple : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: isSmall ? 12 : 13,
          ),
        ),
      ),
    );
  }
}
