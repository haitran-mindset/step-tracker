import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/theme/app_colors.dart';

/// Animated pill badge showing walking or idle status
class WalkingStatusBadge extends StatelessWidget {
  final bool isWalking;

  const WalkingStatusBadge({super.key, required this.isWalking});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.3),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: Container(
            key: ValueKey(isWalking),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: isWalking
                  ? AppColors.secondary.withOpacity(0.15)
                  : AppColors.stepIdle.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isWalking
                    ? AppColors.secondary.withOpacity(0.4)
                    : AppColors.stepIdle.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isWalking)
                  _PulsingDot()
                else
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.stepIdle,
                    ),
                  ),
                const SizedBox(width: 8),
                Text(
                  isWalking ? 'Walking' : 'Resting',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isWalking ? AppColors.secondary : AppColors.stepIdle,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        _AnimatedFootIcon(isWalking: isWalking),
      ],
    );
  }
}

/// Animated footsteps using a Lottie JSON file when walking, static when idle
class _AnimatedFootIcon extends StatelessWidget {
  final bool isWalking;

  const _AnimatedFootIcon({required this.isWalking});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/walking-steps.json',
      width: 80,
      height: 80,
      fit: BoxFit.contain,
      animate: isWalking,
    );
  }
}

/// Pulsing green dot for walking state
class _PulsingDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: 16,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondary.withOpacity(0.25),
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1.5, 1.5),
                duration: 1200.ms,
              )
              .fadeOut(duration: 1200.ms),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
