import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/step_counter_provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/widgets/app_cards.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../widgets/circular_step_indicator.dart';
import '../widgets/goal_achieved_banner.dart';
import '../widgets/stat_mini_card.dart';
import '../widgets/walking_status_badge.dart';
import '../widgets/weekly_overview_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(todayStatsProvider);
    final stepState = ref.watch(stepCounterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── App Bar ───
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                  ),
                  Text(
                    DateFormat('EEEE, MMM d').format(DateTime.now()),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                  ),
                ],
              ),
            ),
            actions: [
              // Theme toggle
              Consumer(builder: (context, ref, _) {
                return IconButton(
                  icon: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                  onPressed: () =>
                      ref.read(themeModeProvider.notifier).toggle(),
                );
              }),
              const SizedBox(width: 8),
            ],
          ),

          // ─── Content ───
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),

                // Walking Status Badge
                WalkingStatusBadge(isWalking: stepState.isWalking)
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: -0.2, end: 0),

                const SizedBox(height: 20),

                // ─── Main Circular Progress ───
                Center(
                  child: CircularStepIndicator(
                    steps: stats.steps,
                    goal: stats.goal,
                    progressRatio: stats.progressRatio,
                    isGoalAchieved: stats.isGoalAchieved,
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 100.ms).scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                      duration: 500.ms,
                    ),

                const SizedBox(height: 28),

                // ─── Stat Cards Row ───
                SectionHeader(title: "Today's Stats"),
                const SizedBox(height: 16),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: [
                    StatMiniCard(
                      label: 'Calories',
                      value: stats.caloriesBurned.toStringAsFixed(0),
                      unit: 'kcal',
                      icon: Icons.local_fire_department_rounded,
                      gradientColors: AppColors.warmGradient,
                    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                    StatMiniCard(
                      label: 'Distance',
                      value: stats.distanceKm.toStringAsFixed(2),
                      unit: 'km',
                      icon: Icons.route_rounded,
                      gradientColors: AppColors.secondaryGradient,
                    ).animate().fadeIn(delay: 250.ms).slideX(begin: 0.2),
                    StatMiniCard(
                      label: 'Active Time',
                      value: '${stats.activeMinutes}',
                      unit: 'min',
                      icon: Icons.timer_rounded,
                      gradientColors: AppColors.coolGradient,
                    ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2),
                    StatMiniCard(
                      label: 'Goal',
                      value:
                          '${(stats.progressRatio * 100).toStringAsFixed(0)}',
                      unit: '%',
                      icon: Icons.flag_rounded,
                      gradientColors: AppColors.primaryGradient,
                    ).animate().fadeIn(delay: 350.ms).slideX(begin: 0.2),
                  ],
                ),

                const SizedBox(height: 28),

                // ─── Goal Achievement Banner (if reached) ───
                if (stats.isGoalAchieved) ...[
                  const GoalAchievedBanner()
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.3),
                  const SizedBox(height: 16),
                ],

                // ─── Weekly Overview Card ───
                const WeeklyOverviewCard()
                    .animate()
                    .fadeIn(delay: 400.ms)
                    .slideY(begin: 0.2),

                const SizedBox(height: 100), // Bottom nav spacing
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning 🌅';
    if (hour < 17) return 'Good afternoon ☀️';
    return 'Good evening 🌙';
  }
}
