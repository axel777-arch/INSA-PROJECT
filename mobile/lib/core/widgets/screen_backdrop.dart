// ============================================================================
// SCREEN BACKDROP
// ----------------------------------------------------------------------------
// Decorative layer used behind every screen in the app: paints the screen's
// solid background colour, a big soft half-circle bleeding off the top edge,
// and a few small accent circles scattered around the page. Purely visual,
// non-interactive, and sits behind the screen's real content.
// ============================================================================

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ScreenBackdrop extends StatelessWidget {
  const ScreenBackdrop({
    super.key,
    required this.child,
    this.showAccents = true,
  });

  /// The screen's real content, painted on top of the backdrop.
  final Widget child;

  /// Whether to draw the small scattered accent circles in addition to the
  /// big top half-circle. Kept on by default; screens can opt out for a
  /// quieter look (e.g. dense list/table screens) by passing `false`.
  final bool showAccents;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    final bg = isDark ? AppColors.backgroundDarkTheme : AppColors.background;
    final primaryCircle = isDark ? AppColors.backdropCirclePrimaryDark : AppColors.backdropCirclePrimary;
    final secondaryCircle = isDark ? AppColors.backdropCircleSecondaryDark : AppColors.backdropCircleSecondary;
    final accentCircle = isDark ? AppColors.backdropCircleAccentDark : AppColors.backdropCircleAccent;

    return Container(
      color: bg,
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Big half-circle: a large full circle positioned so most of it
          // bleeds off the top of the screen, leaving only a soft dome
          // (half-circle) visible at the top.
          Positioned(
            top: -size.width * 0.55,
            left: -size.width * 0.28,
            child: IgnorePointer(
              child: _Circle(
                diameter: size.width * 1.15,
                color: primaryCircle.withValues(alpha: isDark ? 0.55 : 0.55),
              ),
            ),
          ),
          // Second, smaller top half-circle for depth, offset to the right.
          Positioned(
            top: -size.width * 0.42,
            right: -size.width * 0.30,
            child: IgnorePointer(
              child: _Circle(
                diameter: size.width * 0.75,
                color: secondaryCircle.withValues(alpha: isDark ? 0.45 : 0.5),
              ),
            ),
          ),
          if (showAccents) ...[
            // Small accent circles scattered around the page for texture.
            Positioned(
              top: size.height * 0.16,
              right: 28,
              child: IgnorePointer(
                child: _Circle(diameter: 22, color: accentCircle.withValues(alpha: 0.30)),
              ),
            ),
            Positioned(
              top: size.height * 0.30,
              left: 18,
              child: IgnorePointer(
                child: _Circle(diameter: 12, color: secondaryCircle.withValues(alpha: 0.45)),
              ),
            ),
            Positioned(
              bottom: size.height * 0.22,
              right: size.width * 0.14,
              child: IgnorePointer(
                child: _Circle(diameter: 34, color: primaryCircle.withValues(alpha: 0.28)),
              ),
            ),
            Positioned(
              bottom: size.height * 0.10,
              left: size.width * 0.10,
              child: IgnorePointer(
                child: _Circle(diameter: 16, color: accentCircle.withValues(alpha: 0.35)),
              ),
            ),
          ],
          child,
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.diameter, required this.color});

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
