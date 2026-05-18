import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/number_formatter.dart';

class MilestoneCard extends StatelessWidget {
  final int steps;
  final String label;
  final IconData icon;
  final Color color;
  final bool isAchieved;
  final int currentSteps;

  const MilestoneCard({
    super.key,
    required this.steps,
    required this.label,
    required this.icon,
    required this.color,
    required this.isAchieved,
    required this.currentSteps,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = (currentSteps / steps).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isAchieved ? color.withOpacity(0.4) : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isAchieved ? color : color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAchieved ? Icons.check_rounded : icon,
              color: isAchieved ? Colors.white : color,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            )),
                    Text(
                      '${_formatK(steps)} steps',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, _) => LinearProgressIndicator(
                      value: v,
                      backgroundColor: isDark
                          ? AppColors.surfaceDark
                          : const Color(0xFFEEF1FF),
                      valueColor: AlwaysStoppedAnimation<Color>(
                          isAchieved ? color : color.withOpacity(0.7)),
                      minHeight: 6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatK(int n) => NumberFormatter.formatSteps(n);
}
