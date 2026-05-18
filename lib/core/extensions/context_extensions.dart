import 'package:flutter/material.dart';
import 'package:networking_game/core/constants/app_constants.dart';

extension ContextExtensions on BuildContext {
  bool get isMobile => MediaQuery.sizeOf(this).width < AppConstants.mobileBreakpoint;
  bool get isDesktop => MediaQuery.sizeOf(this).width >= AppConstants.mobileBreakpoint;

  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// true when width < 375 (iPhone SE, small Android)
  bool get isSmallScreen => screenWidth < 375;

  /// Responsive padding: 16 on small, 24 on normal
  double get responsivePadding => isSmallScreen ? 14.0 : 24.0;

  /// Responsive font scale factor
  double get fontScale => isSmallScreen ? 0.85 : 1.0;

  /// Scale a font size based on screen width
  double scaledFont(double size) => size * fontScale;

  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }
}
