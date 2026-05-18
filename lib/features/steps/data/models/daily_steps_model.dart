import 'package:hive/hive.dart';

part 'daily_steps_model.g.dart';

/// Hive model for storing daily step data
@HiveType(typeId: 1)
class DailyStepsModel extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final int steps;

  @HiveField(2)
  final int goal;

  @HiveField(3)
  final double caloriesBurned;

  @HiveField(4)
  final double distanceKm;

  @HiveField(5)
  final int activeMinutes;

  DailyStepsModel({
    required this.date,
    required this.steps,
    required this.goal,
    required this.caloriesBurned,
    required this.distanceKm,
    required this.activeMinutes,
  });

  /// Progress percentage toward daily goal (0.0 – 1.0)
  double get progressRatio => (steps / goal).clamp(0.0, 1.0);

  /// Whether today's goal has been achieved
  bool get isGoalAchieved => steps >= goal;

  /// Date key used as Hive box key (YYYY-MM-DD)
  String get dateKey =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  DailyStepsModel copyWith({
    int? steps,
    int? goal,
    double? caloriesBurned,
    double? distanceKm,
    int? activeMinutes,
  }) {
    return DailyStepsModel(
      date: date,
      steps: steps ?? this.steps,
      goal: goal ?? this.goal,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      distanceKm: distanceKm ?? this.distanceKm,
      activeMinutes: activeMinutes ?? this.activeMinutes,
    );
  }
}
