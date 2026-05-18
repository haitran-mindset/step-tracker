import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/stat_filter_provider.dart';

class CaloriesBarChart extends StatelessWidget {
  final StatFilter filter;
  const CaloriesBarChart({super.key, required this.filter});

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
