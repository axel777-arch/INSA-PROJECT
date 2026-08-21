// ============================================================================
// DASHBOARD HERO BACKGROUND
// ----------------------------------------------------------------------------
// The soft rolling-hill gradient + growing-plant illustration that sits
// behind the header/welcome area in the reference design. Pure Flutter
// (CustomPainter), no image assets or extra packages required.
// ============================================================================

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Wrap your [DashboardAppHeader] + [DashboardWelcomeBanner] with this to get
/// the soft green hill gradient and growing-plant illustration behind them,
/// matching the reference design.
class DashboardHeroSection extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const DashboardHeroSection({
    super.key,
    required this.child,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
            child: CustomPaint(
              painter: _HeroBackgroundPainter(isDark: isDark),
              child: const SizedBox(height: double.infinity, width: double.infinity),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _HeroBackgroundPainter extends CustomPainter {
  final bool isDark;
  _HeroBackgroundPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final hillLight = isDark
        ? AppColors.tintGreenBgDark.withValues(alpha: 0.5)
        : AppColors.tintGreenBg.withValues(alpha: 0.7);
    final hillMid = isDark
        ? AppColors.primaryDarkTheme.withValues(alpha: 0.10)
        : AppColors.primaryLight.withValues(alpha: 0.14);
    final leafColor = isDark
        ? AppColors.primaryDarkTheme.withValues(alpha: 0.35)
        : AppColors.primaryLight.withValues(alpha: 0.55);
    final stemColor = isDark
        ? AppColors.primaryDarkTheme.withValues(alpha: 0.45)
        : AppColors.primary.withValues(alpha: 0.55);

    // Back hill.
    final backHill = Path()
      ..moveTo(size.width * 0.35, size.height)
      ..cubicTo(
        size.width * 0.55, size.height * 0.55,
        size.width * 0.85, size.height * 0.35,
        size.width, size.height * 0.55,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(backHill, Paint()..color = hillMid);

    // Front hill.
    final frontHill = Path()
      ..moveTo(size.width * 0.55, size.height)
      ..cubicTo(
        size.width * 0.72, size.height * 0.62,
        size.width * 0.9, size.height * 0.5,
        size.width, size.height * 0.62,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(frontHill, Paint()..color = hillLight);

    // Simple growing-plant illustration, anchored bottom-right.
    final baseX = size.width * 0.86;
    final baseY = size.height;
    final stemTopY = size.height * 0.18;

    final stemPaint = Paint()
      ..color = stemColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final stem = Path()
      ..moveTo(baseX, baseY)
      ..quadraticBezierTo(
        baseX - 6, size.height * 0.55,
        baseX, stemTopY,
      );
    canvas.drawPath(stem, stemPaint);

    void drawLeaf(Offset origin, double angleDeg, double length) {
      canvas.save();
      canvas.translate(origin.dx, origin.dy);
      canvas.rotate(angleDeg * 3.14159 / 180);
      final leaf = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(length * 0.5, -length * 0.5, length, 0)
        ..quadraticBezierTo(length * 0.5, length * 0.35, 0, 0);
      canvas.drawPath(leaf, Paint()..color = leafColor);
      canvas.restore();
    }

    drawLeaf(Offset(baseX - 2, size.height * 0.62), -20, 46);
    drawLeaf(Offset(baseX + 2, size.height * 0.45), 200, 42);
    drawLeaf(Offset(baseX - 1, size.height * 0.30), -25, 34);
    drawLeaf(Offset(baseX + 1, stemTopY + 6), 205, 30);
  }

  @override
  bool shouldRepaint(covariant _HeroBackgroundPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
