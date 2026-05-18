import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../features/settings/data/models/user_profile_model.dart';
import '../../../../shared/widgets/app_cards.dart';

class BodyInfoCard extends StatelessWidget {
  final UserProfileModel profile;

  const BodyInfoCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return NeumorphicCard(
      child: Column(
        children: [
          _InfoRow(
            label: 'Height',
            value: '${profile.height.toStringAsFixed(0)} cm',
            icon: Icons.height_rounded,
          ),
          const Divider(height: 24),
          _InfoRow(
            label: 'Weight',
            value: '${profile.weight.toStringAsFixed(1)} kg',
            icon: Icons.monitor_weight_rounded,
          ),
          const Divider(height: 24),
          _InfoRow(
            label: 'Age',
            value: '${profile.age} years',
            icon: Icons.cake_rounded,
          ),
          const Divider(height: 24),
          _InfoRow(
            label: 'Gender',
            value: _capitalize(profile.gender),
            icon: Icons.person_rounded,
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 14),
        Text(
          label,
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}
