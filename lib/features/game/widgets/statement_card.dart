import 'package:flutter/material.dart';
import 'package:networking_game/core/theme/app_colors.dart';
import 'package:networking_game/core/widgets/glassmorphism_card.dart';

class StatementCard extends StatelessWidget {
  final int index;
  final String statement;
  final bool isSelected;
  final bool isRevealed;
  final bool isLie;
  final bool isSmall;
  final VoidCallback? onTap;

  const StatementCard({
    super.key,
    required this.index,
    required this.statement,
    this.isSelected = false,
    this.isRevealed = false,
    this.isLie = false,
    this.isSmall = false,
    this.onTap,
  });

  Color get _borderColor {
    if (isRevealed) {
      return isLie ? AppColors.errorRed : AppColors.accentGreen;
    }
    if (isSelected) return AppColors.electricBlue;
    return Colors.white.withValues(alpha: 0.15);
  }

  Color get _bgColor {
    if (isRevealed) {
      return isLie
          ? AppColors.errorRed.withValues(alpha: 0.15)
          : AppColors.accentGreen.withValues(alpha: 0.15);
    }
    if (isSelected) return AppColors.electricBlue.withValues(alpha: 0.15);
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final circleSize = isSmall ? 32.0 : 40.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        child: GlassmorphismCard(
          color: _bgColor,
          border: Border.all(color: _borderColor, width: 2),
          padding: EdgeInsets.all(isSmall ? 12 : 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Number circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected || isRevealed
                      ? _borderColor.withValues(alpha: 0.3)
                      : AppColors.primaryPurple.withValues(alpha: 0.2),
                  border: Border.all(color: _borderColor),
                ),
                child: Center(
                  child: isRevealed
                      ? Icon(
                          isLie ? Icons.close : Icons.check,
                          color: _borderColor,
                          size: isSmall ? 16 : 20,
                        )
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.electricBlue
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: isSmall ? 13 : 16,
                          ),
                        ),
                ),
              ),
              SizedBox(width: isSmall ? 10 : 16),
              // Statement
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statement,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: isSmall ? 13 : 15,
                        height: 1.4,
                      ),
                    ),
                    if (isRevealed) ...[
                      const SizedBox(height: 4),
                      Text(
                        isLie ? 'This is the LIE!' : 'This is TRUE',
                        style: TextStyle(
                          color: _borderColor,
                          fontSize: isSmall ? 10 : 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!isRevealed) ...[
                const SizedBox(width: 8),
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? AppColors.electricBlue : AppColors.textSecondary,
                  size: isSmall ? 20 : 24,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
