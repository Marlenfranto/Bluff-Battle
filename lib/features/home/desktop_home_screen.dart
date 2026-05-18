import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:networking_game/core/theme/app_colors.dart';
import 'package:networking_game/core/widgets/animated_gradient_background.dart';
import 'package:networking_game/core/widgets/glassmorphism_card.dart';
import 'package:networking_game/features/dashboard/dashboard_screen.dart';
import 'package:networking_game/features/leaderboard/leaderboard_screen.dart';
import 'package:networking_game/features/dashboard/widgets/participant_table.dart';
import 'package:networking_game/providers/auth_provider.dart';
import 'package:networking_game/providers/theme_provider.dart';

class DesktopHomeScreen extends ConsumerStatefulWidget {
  const DesktopHomeScreen({super.key});

  @override
  ConsumerState<DesktopHomeScreen> createState() => _DesktopHomeScreenState();
}

class _DesktopHomeScreenState extends ConsumerState<DesktopHomeScreen> {
  int _selectedIndex = 0;

  final _navItems = const [
    _NavItemData(icon: Icons.dashboard_rounded, label: 'Dashboard'),
    _NavItemData(icon: Icons.emoji_events_rounded, label: 'Leaderboard'),
    _NavItemData(icon: Icons.people_rounded, label: 'Participants'),
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      body: AnimatedGradientBackground(
        child: authState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryPurple),
          ),
          error: (e, _) => Center(
            child: Text('Auth error: $e',
                style: const TextStyle(color: AppColors.errorRed)),
          ),
          data: (user) {
            if (user == null) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primaryPurple),
                    SizedBox(height: 16),
                    Text('Connecting...',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              );
            }

            return Row(
              children: [
                _Sidebar(
                  selectedIndex: _selectedIndex,
                  items: _navItems,
                  onItemTap: (i) => setState(() => _selectedIndex = i),
                  onThemeToggle: () =>
                      ref.read(themeModeProvider.notifier).toggle(),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.02, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _buildPage(_selectedIndex),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const DashboardScreen(key: ValueKey('dashboard'));
      case 1:
        return const LeaderboardScreen(key: ValueKey('leaderboard'));
      case 2:
        return const ParticipantTable(key: ValueKey('participants'));
      default:
        return const DashboardScreen(key: ValueKey('dashboard'));
    }
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  const _NavItemData({required this.icon, required this.label});
}

class _Sidebar extends StatelessWidget {
  final int selectedIndex;
  final List<_NavItemData> items;
  final ValueChanged<int> onItemTap;
  final VoidCallback onThemeToggle;

  const _Sidebar({
    required this.selectedIndex,
    required this.items,
    required this.onItemTap,
    required this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.all(12),
      child: GlassmorphismCard(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 10),
        borderRadius: 20,
        child: Column(
          children: [
            // Logo
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withValues(alpha: 0.3),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  'assets/images/bingo.png',
                  width: 48,
                  height: 48,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 36),

            // Nav items
            ...items.asMap().entries.map((e) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SidebarItem(
                  icon: e.value.icon,
                  label: e.value.label,
                  isSelected: e.key == selectedIndex,
                  onTap: () => onItemTap(e.key),
                ),
              );
            }),

            const Spacer(),

            // Theme toggle
            _SidebarItem(
              icon: Icons.brightness_6,
              label: 'Theme',
              isSelected: false,
              onTap: onThemeToggle,
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isSelected || _isHovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Tooltip(
          message: widget.label,
          waitDuration: const Duration(milliseconds: 500),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: widget.isSelected
                  ? LinearGradient(
                      colors: [
                        AppColors.primaryPurple.withValues(alpha: 0.25),
                        AppColors.electricBlue.withValues(alpha: 0.15),
                      ],
                    )
                  : null,
              color: !widget.isSelected && _isHovered
                  ? Colors.white.withValues(alpha: 0.08)
                  : null,
              borderRadius: BorderRadius.circular(14),
              border: widget.isSelected
                  ? Border.all(
                      color: AppColors.primaryPurple.withValues(alpha: 0.5),
                    )
                  : null,
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryPurple.withValues(alpha: 0.2),
                        blurRadius: 12,
                      ),
                    ]
                  : null,
            ),
            child: AnimatedScale(
              scale: _isHovered ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: Icon(
                widget.icon,
                color: isActive ? AppColors.primaryPurple : AppColors.textSecondary,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
