import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/step_counter_provider.dart';
import '../../../../shared/widgets/app_cards.dart';
import '../../../../shared/widgets/common_widgets.dart';

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
                _SetGoalSection(currentGoal: goal)
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
      return _MilestoneCard(
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

// ──────────────────── Set Goal Section ────────────────────

class _SetGoalSection extends ConsumerStatefulWidget {
  final int currentGoal;
  const _SetGoalSection({required this.currentGoal});

  @override
  ConsumerState<_SetGoalSection> createState() => _SetGoalSectionState();
}

class _SetGoalSectionState extends ConsumerState<_SetGoalSection> {
  late int _selected;
  static const _presets = [5000, 7500, 10000, 12500, 15000];

  @override
  void initState() {
    super.initState();
    _selected = widget.currentGoal;
  }

  @override
  Widget build(BuildContext context) {
    return NeumorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Set Daily Goal'),
          const SizedBox(height: 16),

          // Preset chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presets.map((p) {
              final isSelected = _selected == p;
              return ChoiceChip(
                label: Text(_formatSteps(p)),
                selected: isSelected,
                onSelected: (_) {
                  setState(() => _selected = p);
                  HapticFeedback.lightImpact();
                  ref.read(dailyGoalProvider.notifier).setGoal(p);
                },
                selectedColor: AppColors.primary,
                backgroundColor:
                    Theme.of(context).brightness == Brightness.dark
                        ? AppColors.surfaceDark
                        : const Color(0xFFF0F1FF),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected
                        ? Colors.transparent
                        : AppColors.primary.withOpacity(0.2),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Custom goal slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.primary.withOpacity(0.2),
              thumbColor: Colors.white,
              overlayColor: AppColors.primary.withOpacity(0.15),
            ),
            child: Slider(
              min: 1000,
              max: 20000,
              divisions: 38,
              value: _selected.toDouble(),
              onChanged: (v) {
                setState(() => _selected = v.round());
              },
              onChangeEnd: (v) {
                ref.read(dailyGoalProvider.notifier).setGoal(v.round());
                HapticFeedback.selectionClick();
              },
            ),
          ),

          Center(
            child: Text(
              _formatSteps(_selected),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatSteps(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k steps';
    return '$n steps';
  }
}

// ──────────────────── Milestone Card ────────────────────

class _MilestoneCard extends StatelessWidget {
  final int steps;
  final String label;
  final IconData icon;
  final Color color;
  final bool isAchieved;
  final int currentSteps;

  const _MilestoneCard({
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

  String _formatK(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(0)}k' : '$n';
}
