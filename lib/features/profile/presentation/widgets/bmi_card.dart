import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_cards.dart';

class BmiCard extends StatelessWidget {
  final double bmi;
  final String category;

  const BmiCard({super.key, required this.bmi, required this.category});

  Color _bmiColor() {
    if (bmi < 18.5) return AppColors.accentBlue;
    if (bmi < 25.0) return AppColors.secondary;
    if (bmi < 30.0) return AppColors.accentOrange;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final color = _bmiColor();

    return GradientCard(
      colors: [color, color.withOpacity(0.7)],
      shadows: [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.monitor_heart_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'BMI Score',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  bmi.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.health_and_safety_rounded,
              color: Colors.white54, size: 80),
        ],
      ),
    );
  }
}
