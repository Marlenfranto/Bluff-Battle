import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:networking_game/core/theme/app_colors.dart';
import 'package:networking_game/core/extensions/context_extensions.dart';
import 'package:networking_game/features/profile/profile_view_screen.dart';
import 'package:networking_game/features/scanner/scanner_screen.dart';
import 'package:networking_game/features/connections/connections_screen.dart';
import 'package:networking_game/features/profile/profile_setup_screen.dart';

class MobileHomeScreen extends ConsumerStatefulWidget {
  const MobileHomeScreen({super.key});

  @override
  ConsumerState<MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends ConsumerState<MobileHomeScreen> {
  int _currentIndex = 0;

  Widget _buildScreen(int index) {
    // Only build the scanner when its tab is active
    switch (index) {
      case 0:
        return const ProfileViewScreen();
      case 1:
        return _currentIndex == 1
            ? const ScannerScreen()
            : const SizedBox.shrink();
      case 2:
        return const ConnectionsScreen();
      case 3:
        return const ProfileSetupScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = context.isSmallScreen;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: List.generate(4, _buildScreen),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 4 : 8,
              vertical: isSmall ? 6 : 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.qr_code,
                  label: 'My QR',
                  isSelected: _currentIndex == 0,
                  isSmall: isSmall,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  icon: Icons.qr_code_scanner,
                  label: 'Scan',
                  isSelected: _currentIndex == 1,
                  isSmall: isSmall,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _NavItem(
                  icon: Icons.people,
                  label: 'Contacts',
                  isSelected: _currentIndex == 2,
                  isSmall: isSmall,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _NavItem(
                  icon: Icons.person,
                  label: 'Profile',
                  isSelected: _currentIndex == 3,
                  isSmall: isSmall,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isSmall;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isSmall,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 10 : 16,
          vertical: isSmall ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryPurple.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryPurple : AppColors.textSecondary,
              size: isSmall ? 20 : 24,
            ),
            SizedBox(height: isSmall ? 2 : 4),
            Text(
              label,
              style: TextStyle(
                fontSize: isSmall ? 9 : 11,
                color: isSelected ? AppColors.primaryPurple : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
