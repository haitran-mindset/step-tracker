import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_cards.dart';
import '../../../../shared/widgets/common_widgets.dart';

class WeeklyOverviewCard extends ConsumerWidget {
  const WeeklyOverviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Mock 7-day data
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final values = [8200, 6500, 10200, 5100, 9800, 4300, 7500];
    final today = DateTime.now().weekday - 1; // 0=Mon

    return NeumorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'This Week'),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final ratio = (values[i] / 10000).clamp(0.0, 1.0);
              final isToday = i == today;
              return _DayBar(
                day: days[i],
                ratio: ratio,
                isToday: isToday,
                steps: values[i],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  final String day;
  final double ratio;
  final bool isToday;
  final int steps;

  const _DayBar({
    required this.day,
    required this.ratio,
    required this.isToday,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    const barHeight = 80.0;
    final color =
        isToday ? AppColors.primary : AppColors.primary.withOpacity(0.35);

    return Column(
      children: [
        Container(
          width: 36,
          height: barHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.surfaceDark
                : const Color(0xFFF0F1FF),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.bottomCenter,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: ratio),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => Container(
              height: barHeight * v,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isToday ? AppColors.primaryGradient : [color, color],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
            color: isToday
                ? AppColors.primary
                : Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
