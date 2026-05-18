import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../features/steps/data/repositories/steps_repository.dart';
import '../../../../shared/widgets/app_cards.dart';
import '../../../../shared/widgets/common_widgets.dart';

enum StatFilter { today, week, month }

final _filterProvider = StateProvider<StatFilter>((ref) => StatFilter.week);

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(_filterProvider);
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
                _FilterChips(selected: filter).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 24),

                // ─── Summary Cards Row ───
                _SummaryRow(filter: filter)
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
                      _StepsLineChart(filter: filter),
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
                      _CaloriesBarChart(filter: filter),
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

// ──────────────────── Filter Chips ────────────────────

class _FilterChips extends ConsumerWidget {
  final StatFilter selected;
  const _FilterChips({required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: StatFilter.values.map((f) {
        final isSelected = f == selected;
        final label = f.name[0].toUpperCase() + f.name.substring(1);

        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            child: FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) =>
                  ref.read(_filterProvider.notifier).state = f,
              selectedColor: AppColors.primary,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.cardDark
                  : AppColors.cardLight,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : null,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
              side: BorderSide(
                color: isSelected ? Colors.transparent : AppColors.primary.withOpacity(0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ──────────────────── Summary Row ────────────────────

class _SummaryRow extends StatelessWidget {
  final StatFilter filter;
  const _SummaryRow({required this.filter});

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

// ──────────────────── Steps Line Chart ────────────────────

class _StepsLineChart extends StatelessWidget {
  final StatFilter filter;
  const _StepsLineChart({required this.filter});

  List<FlSpot> get _spots {
    // Mock step data
    final weekData = [6200, 8500, 7100, 10200, 5400, 9800, 7523];
    return weekData.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.toDouble());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            getDrawingHorizontalLine: (value) => FlLine(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.05),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
            getDrawingVerticalLine: (_) => FlLine(
              color: Colors.transparent,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (v, meta) => Text(
                  '${(v / 1000).toStringAsFixed(0)}k',
                  style: TextStyle(fontSize: 10, color: labelColor),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, meta) {
                  const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                  final i = v.toInt();
                  if (i < 0 || i >= days.length) return const SizedBox();
                  return Text(
                    days[i],
                    style: TextStyle(fontSize: 11, color: labelColor, fontWeight: FontWeight.w600),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _spots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: AppColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                  radius: 5,
                  color: Colors.white,
                  strokeWidth: 3,
                  strokeColor: AppColors.primary,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.3),
                    AppColors.primary.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          minY: 0,
          maxY: 12000,
        ),
      ),
    );
  }
}

// ──────────────────── Calories Bar Chart ────────────────────

class _CaloriesBarChart extends StatelessWidget {
  final StatFilter filter;
  const _CaloriesBarChart({required this.filter});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final data = [248.0, 340.0, 284.0, 408.0, 216.0, 392.0, 301.0];

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 500,
          gridData: FlGridData(
            show: true,
            getDrawingHorizontalLine: (v) => FlLine(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.05),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
            getDrawingVerticalLine: (_) => FlLine(color: Colors.transparent),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, meta) {
                  const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                  final i = v.toInt();
                  if (i < 0 || i >= days.length) return const SizedBox();
                  return Text(
                    days[i],
                    style: TextStyle(fontSize: 11, color: labelColor, fontWeight: FontWeight.w600),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (v, meta) => Text(
                  '${v.toInt()}',
                  style: TextStyle(fontSize: 10, color: labelColor),
                ),
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: data.asMap().entries.map((e) {
            final isLast = e.key == data.length - 1;
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value,
                  gradient: LinearGradient(
                    colors: isLast
                        ? AppColors.primaryGradient
                        : AppColors.warmGradient,
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: 28,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
