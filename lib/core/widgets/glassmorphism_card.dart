import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:networking_game/core/theme/app_colors.dart';

class GlassmorphismCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? color;
  final double blur;
  final double opacity;
  final Border? border;
  final bool hoverable;

  const GlassmorphismCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
    this.color,
    this.blur = 10,
    this.opacity = 0.1,
    this.border,
    this.hoverable = false,
  });

  @override
  State<GlassmorphismCard> createState() => _GlassmorphismCardState();
}

class _GlassmorphismCardState extends State<GlassmorphismCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final cardColor = widget.color ?? Colors.white;
    final effectiveOpacity = _isHovered && widget.hoverable
        ? widget.opacity + 0.06
        : widget.opacity;

    Widget card;

    if (kIsWeb) {
      card = AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: cardColor.withValues(alpha: effectiveOpacity + 0.05),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: widget.border ??
              Border.all(
                color: cardColor.withValues(
                    alpha: _isHovered && widget.hoverable ? 0.25 : 0.12),
                width: 1.5,
              ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPurple.withValues(
                  alpha: _isHovered && widget.hoverable ? 0.12 : 0.04),
              blurRadius: _isHovered && widget.hoverable ? 20 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: widget.child,
      );
    } else {
      card = ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
          child: Container(
            padding: widget.padding,
            decoration: BoxDecoration(
              color: cardColor.withValues(alpha: widget.opacity),
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: widget.border ??
                  Border.all(
                    color: cardColor.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
            ),
            child: widget.child,
          ),
        ),
      );
    }

    if (widget.hoverable) {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: card,
        ),
      );
    }

    return card;
  }
}
