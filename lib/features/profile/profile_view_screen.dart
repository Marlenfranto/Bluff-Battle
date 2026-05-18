import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:networking_game/core/theme/app_colors.dart';
import 'package:networking_game/core/constants/app_constants.dart';
import 'package:networking_game/core/widgets/animated_gradient_background.dart';
import 'package:networking_game/core/widgets/glassmorphism_card.dart';
import 'package:networking_game/core/widgets/animated_button.dart';
import 'package:networking_game/core/extensions/context_extensions.dart';
import 'package:networking_game/providers/auth_provider.dart';
import 'package:networking_game/providers/user_provider.dart';
import 'package:networking_game/services/qr_service.dart';
import 'package:networking_game/services/download_service.dart';

class ProfileViewScreen extends ConsumerWidget {
  const ProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final userId = ref.watch(currentUserIdProvider);

    return AnimatedGradientBackground(
      child: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (profile) {
            if (profile == null || userId == null) {
              return const Center(child: Text('No profile found'));
            }
            final qrData = QrService().generateQrData(userId);
            return _ProfileContent(profile: profile, qrData: qrData);
          },
        ),
      ),
    );
  }
}

class _ProfileContent extends StatefulWidget {
  final dynamic profile;
  final String qrData;

  const _ProfileContent({required this.profile, required this.qrData});

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> {
  final GlobalKey _qrKey = GlobalKey();

  Future<void> _downloadQr() async {
    try {
      final boundary = _qrKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      DownloadService.downloadBytes(bytes, 'my_qr_code.png');

      if (mounted) {
        context.showSuccessSnackBar('QR code downloaded!');
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Failed to download QR: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final isSmall = context.isSmallScreen;
    final pad = context.responsivePadding;
    final screenWidth = context.screenWidth;

    // QR size: responsive, leave room for padding
    final qrSize = (screenWidth - pad * 2 - 80).clamp(180.0, 300.0);
    final avatarSize = isSmall ? 56.0 : 72.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(
        children: [
          SizedBox(height: isSmall ? 4 : 8),
          // Avatar
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.4),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Center(
              child: Text(
                profile.name.isNotEmpty
                    ? profile.name[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: isSmall ? 24 : 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: isSmall ? 8 : 12),

          // Name
          Text(
            profile.name,
            style: TextStyle(
              fontSize: isSmall ? 18 : 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${AppConstants.getRankEmoji(profile.rank)} ${profile.rank}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: isSmall ? 11 : 12,
              ),
            ),
          ),
          SizedBox(height: isSmall ? 16 : 20),

          // QR Code Card
          GlassmorphismCard(
            padding: EdgeInsets.all(isSmall ? 14 : 20),
            child: Column(
              children: [
                Text(
                  'Your QR Code',
                  style: TextStyle(
                    fontSize: isSmall ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: isSmall ? 12 : 16),
                RepaintBoundary(
                  key: _qrKey,
                  child: Container(
                    padding: EdgeInsets.all(isSmall ? 14 : 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: QrImageView(
                      data: widget.qrData,
                      version: QrVersions.auto,
                      size: qrSize,
                      errorCorrectionLevel: QrErrorCorrectLevel.H,
                      gapless: true,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Colors.black,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isSmall ? 12 : 16),

                AnimatedButton(
                  onPressed: _downloadQr,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmall ? 16 : 24,
                    vertical: isSmall ? 10 : 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.download, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Download QR',
                        style: TextStyle(fontSize: isSmall ? 13 : 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Let others scan to play!',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: isSmall ? 11 : 13,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isSmall ? 14 : 20),

          // Stats
          _StatsGrid(profile: profile, isSmall: isSmall),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final dynamic profile;
  final bool isSmall;

  const _StatsGrid({required this.profile, required this.isSmall});

  @override
  Widget build(BuildContext context) {
    final gap = isSmall ? 6.0 : 10.0;
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _StatBox(label: 'Score', value: '${profile.score}', icon: Icons.star, color: AppColors.accentOrange, isSmall: isSmall)),
            SizedBox(width: gap),
            Expanded(child: _StatBox(label: 'Scans', value: '${profile.totalScans}', icon: Icons.qr_code_scanner, color: AppColors.electricBlue, isSmall: isSmall)),
            SizedBox(width: gap),
            Expanded(child: _StatBox(label: 'Accuracy', value: '${profile.accuracy.toStringAsFixed(0)}%', icon: Icons.track_changes, color: AppColors.accentGreen, isSmall: isSmall)),
          ],
        ),
        SizedBox(height: gap),
        Row(
          children: [
            Expanded(child: _StatBox(label: 'Links', value: '${profile.connections.length}', icon: Icons.people, color: AppColors.neonPink, isSmall: isSmall)),
            SizedBox(width: gap),
            Expanded(child: _StatBox(label: 'Correct', value: '${profile.correctGuesses}', icon: Icons.check_circle, color: AppColors.accentGreen, isSmall: isSmall)),
            SizedBox(width: gap),
            Expanded(child: _StatBox(label: 'Wrong', value: '${profile.wrongGuesses}', icon: Icons.cancel, color: AppColors.errorRed, isSmall: isSmall)),
          ],
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isSmall;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isSmall,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphismCard(
      padding: EdgeInsets.symmetric(
        vertical: isSmall ? 10 : 14,
        horizontal: isSmall ? 6 : 10,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: isSmall ? 18 : 22),
          SizedBox(height: isSmall ? 4 : 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: isSmall ? 15 : 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: isSmall ? 9 : 11,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
