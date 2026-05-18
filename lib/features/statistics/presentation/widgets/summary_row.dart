import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/stat_filter_provider.dart';

class SummaryRow extends StatelessWidget {
  final StatFilter filter;
  const SummaryRow({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    // Mock aggregated data
    final (totalSteps, avgSteps, bestDay) = switch (filter) {
      StatFilter.today => (7523, 7523, 7523),
      StatFilter.week => (52840, 7548, 10200),
      StatFilter.month => (215600, 7186, 12300),
    };

    return Row(
      children: [
        Expanded(
          child: _SummaryChip(
            label: 'Total',
            value: _formatSteps(totalSteps),
            icon: Icons.directions_walk_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryChip(
            label: 'Average',
            value: _formatSteps(avgSteps),
            icon: Icons.show_chart_rounded,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryChip(
            label: 'Best',
            value: _formatSteps(bestDay),
            icon: Icons.emoji_events_rounded,
            color: AppColors.accentOrange,
          ),
        ),
      ],
    );
  }

  String _formatSteps(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
