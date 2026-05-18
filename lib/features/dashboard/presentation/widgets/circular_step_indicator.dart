import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/common_widgets.dart';

/// Premium circular progress indicator for the main step counter
class CircularStepIndicator extends StatelessWidget {
  final int steps;
  final int goal;
  final double progressRatio;
  final bool isGoalAchieved;

  const CircularStepIndicator({
    super.key,
    required this.steps,
    required this.goal,
    required this.progressRatio,
    this.isGoalAchieved = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: isGoalAchieved
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ]
                : [],
          ),
        ),

        // Progress arc
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progressRatio),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) {
            return CustomPaint(
              size: const Size(260, 260),
              painter: _ArcPainter(
                progress: value,
                isDark: isDark,
                isGoalAchieved: isGoalAchieved,
              ),
            );
          },
        ),

        // Center content
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Step icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: AppColors.primaryGradient),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Icon(
                Icons.directions_walk_rounded,
                color: Colors.white,
                size: 22,
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(
                  begin: 1.0,
                  end: 1.1,
                  duration: 1500.ms,
                  curve: Curves.easeInOut,
                ),

            const SizedBox(height: 12),

            // Step count with animated counter
            AnimatedCounter(
              value: steps,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    letterSpacing: -2,
                  ),
            ),

            const SizedBox(height: 4),

            Text(
              'STEPS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),

            const SizedBox(height: 8),

            // Goal label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Goal: ${_formatNumber(goal)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(0)}k';
    }
    return n.toString();
  }
}

/// Custom arc painter for the circular progress ring
class _ArcPainter extends CustomPainter {
  final double progress;
  final bool isDark;
  final bool isGoalAchieved;

  _ArcPainter({
    required this.progress,
    required this.isDark,
    required this.isGoalAchieved,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 12;
    final strokeWidth = 18.0;

    // Background track
    final trackPaint = Paint()
      ..color = isDark
          ? AppColors.surfaceDark.withOpacity(0.8)
          : const Color(0xFFEEF1FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Gradient progress arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + 2 * math.pi,
      colors: isGoalAchieved
          ? [AppColors.secondary, AppColors.primary]
          : AppColors.primaryGradient,
      stops: const [0.0, 1.0],
    );

    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );

    // Dot at end of arc
    if (progress > 0.02) {
      final angle = -math.pi / 2 + 2 * math.pi * progress;
      final dotX = center.dx + radius * math.cos(angle);
      final dotY = center.dy + radius * math.sin(angle);

      final dotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(dotX, dotY), strokeWidth / 2 - 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.isGoalAchieved != isGoalAchieved;
}
