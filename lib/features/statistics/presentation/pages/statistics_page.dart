import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../features/steps/data/repositories/steps_repository.dart';
import '../../../../shared/widgets/app_cards.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../providers/stat_filter_provider.dart';
import '../widgets/calories_bar_chart.dart';
import '../widgets/filter_chips.dart';
import '../widgets/steps_line_chart.dart';
import '../widgets/summary_row.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(statFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── App Bar ───
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.transparent,
            title: Text(
              'Statistics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ─── Filter Chips ───
                FilterChips(selected: filter).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 24),

                // ─── Summary Cards Row ───
                SummaryRow(filter: filter)
                    .animate()
                    .fadeIn(delay: 100.ms)
                    .slideY(begin: 0.2),

                const SizedBox(height: 24),

                // ─── Line Chart (Steps) ───
                NeumorphicCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(title: 'Daily Steps'),
                      const SizedBox(height: 20),
                      StepsLineChart(filter: filter),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                const SizedBox(height: 20),

                // ─── Bar Chart (Calories) ───
                NeumorphicCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(title: 'Calories Burned'),
                      const SizedBox(height: 20),
                      CaloriesBarChart(filter: filter),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}


