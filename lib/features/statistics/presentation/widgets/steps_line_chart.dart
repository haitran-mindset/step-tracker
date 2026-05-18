import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/number_formatter.dart';
import '../providers/stat_filter_provider.dart';

class StepsLineChart extends StatelessWidget {
  final StatFilter filter;
  const StepsLineChart({super.key, required this.filter});

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
                getTitlesWidget: (v, meta) {
                  return Text(
                    NumberFormatter.formatSteps(v),
                    style: TextStyle(fontSize: 10, color: labelColor),
                  );
                },
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
