import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:networking_game/core/theme/app_colors.dart';
import 'package:networking_game/core/widgets/glassmorphism_card.dart';
import 'package:networking_game/core/extensions/context_extensions.dart';
import 'package:networking_game/models/user_profile.dart';

class ConnectionCard extends StatelessWidget {
  final UserProfile connection;

  const ConnectionCard({super.key, required this.connection});

  Future<void> _openLinkedIn() async {
    final webUrl = connection.linkedInUrl;
    final slugMatch = RegExp(r'linkedin\.com/in/([^/?]+)').firstMatch(webUrl);
    final slug = slugMatch?.group(1);

    if (slug != null) {
      final appUri = Uri.parse('linkedin://in/$slug');
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
        return;
      }
    }

    final url = Uri.parse(webUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = context.isSmallScreen;
    final avatarSize = isSmall ? 40.0 : 48.0;

    return GlassmorphismCard(
      padding: EdgeInsets.all(isSmall ? 12 : 16),
      child: Row(
        children: [
          // Avatar
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                connection.name.isNotEmpty
                    ? connection.name[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: isSmall ? 16 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: isSmall ? 10 : 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  connection.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isSmall ? 14 : 16,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (connection.email != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    connection.email!,
                    style: TextStyle(
                      fontSize: isSmall ? 11 : 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (connection.phone != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    connection.phone!,
                    style: TextStyle(
                      fontSize: isSmall ? 11 : 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // LinkedIn button
          if (connection.linkedInUrl.isNotEmpty)
            GestureDetector(
              onTap: _openLinkedIn,
              child: Container(
                padding: EdgeInsets.all(isSmall ? 6 : 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A66C2).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.link,
                  color: const Color(0xFF0A66C2),
                  size: isSmall ? 18 : 20,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
