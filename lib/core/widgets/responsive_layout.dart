import 'package:flutter/material.dart';
import 'package:networking_game/core/constants/app_constants.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget desktopBody;

  const ResponsiveLayout({
    super.key,
    required this.mobileBody,
    required this.desktopBody,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppConstants.mobileBreakpoint) {
          return mobileBody;
        }
        return desktopBody;
      },
    );
  }
}
