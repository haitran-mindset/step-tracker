import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/step_counter_provider.dart';
import '../../../../shared/widgets/app_cards.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../widgets/milestone_card.dart';
import '../widgets/set_goal_section.dart';

class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(dailyGoalProvider);
    final todayStats = ref.watch(todayStatsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final progressRatio = todayStats.progressRatio;
    final remaining = (goal - todayStats.steps).clamp(0, goal);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.transparent,
            title: Text(
              'My Goals',
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
                // ─── Main Goal Card ───
                GradientCard(
                  colors: AppColors.primaryGradient,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.flag_rounded,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Daily Step Goal',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$goal',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              'steps',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: progressRatio),
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) {
                            return LinearProgressIndicator(
                              value: value,
                              backgroundColor: Colors.white.withOpacity(0.25),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                              minHeight: 8,
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${todayStats.steps} walked',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '$remaining remaining',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),

                const SizedBox(height: 24),

                // ─── Set Goal Button ───
                SetGoalSection(currentGoal: goal)
                    .animate()
                    .fadeIn(delay: 150.ms)
                    .slideY(begin: 0.2),

                const SizedBox(height: 24),

                // ─── Progress Ring ───
                NeumorphicCard(
                  child: Column(
                    children: [
                      SectionHeader(title: "Today's Progress"),
                      const SizedBox(height: 20),
                      Center(
                        child: CircularPercentIndicator(
                          radius: 100,
                          lineWidth: 14,
                          percent: progressRatio,
                          animation: true,
                          animationDuration: 1200,
                          curve: Curves.easeOutCubic,
                          center: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${(progressRatio * 100).toStringAsFixed(0)}%',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimaryLight,
                                    ),
                              ),
                              Text(
                                'Complete',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                          progressColor: todayStats.isGoalAchieved
                              ? AppColors.secondary
                              : AppColors.primary,
                          backgroundColor: isDark
                              ? AppColors.surfaceDark
                              : const Color(0xFFEEF1FF),
                          circularStrokeCap: CircularStrokeCap.round,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 24),

                // ─── Milestone Cards ───
                SectionHeader(title: 'Milestones'),
                const SizedBox(height: 12),
                ..._buildMilestones(context, todayStats.steps)
                    .asMap()
                    .entries
                    .map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: e.value
                              .animate()
                              .fadeIn(delay: Duration(milliseconds: 300 + e.key * 50))
                              .slideX(begin: 0.2),
                        )),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMilestones(BuildContext context, int currentSteps) {
    final milestones = [
      (1000, 'Warm Up', Icons.local_fire_department_rounded, AppColors.accentOrange),
      (2500, 'Getting Moving', Icons.directions_walk_rounded, AppColors.secondary),
      (5000, 'Halfway There', Icons.directions_run_rounded, AppColors.accentBlue),
      (7500, 'Almost There', Icons.speed_rounded, AppColors.primary),
      (10000, 'Goal Reached!', Icons.emoji_events_rounded, AppColors.accentOrange),
    ];

    return milestones.map((m) {
      final isAchieved = currentSteps >= m.$1;
      return MilestoneCard(
        steps: m.$1,
        label: m.$2,
        icon: m.$3,
        color: m.$4,
        isAchieved: isAchieved,
        currentSteps: currentSteps,
      );
    }).toList();
  }
}
