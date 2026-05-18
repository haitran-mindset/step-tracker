import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../features/settings/data/models/user_profile_model.dart';

class StatsOverview extends StatelessWidget {
  final UserProfileModel profile;
  final int totalSteps;

  const StatsOverview({super.key, required this.profile, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        _StatChip(
          value: '$totalSteps',
          label: 'Lifetime Steps',
          icon: Icons.directions_walk_rounded,
          color: AppColors.primary,
          isDark: isDark,
        ),
        const SizedBox(width: 12),
        _StatChip(
          value: '${(totalSteps * 0.762 / 1000).toStringAsFixed(0)} km',
          label: 'Total Distance',
          icon: Icons.route_rounded,
          color: AppColors.secondary,
          isDark: isDark,
        ),
        const SizedBox(width: 12),
        _StatChip(
          value: '${(totalSteps * 0.04).toStringAsFixed(0)}',
          label: 'kcal Burned',
          icon: Icons.local_fire_department_rounded,
          color: AppColors.accentOrange,
          isDark: isDark,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatChip({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
