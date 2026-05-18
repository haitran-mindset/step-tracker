import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/daily_steps_model.dart';

/// Repository for persisting and retrieving daily step data from Hive
class StepsRepository {
  Box<DailyStepsModel> get _box =>
      Hive.box<DailyStepsModel>(AppConstants.stepsBox);

  /// Save (or update) today's step record
  Future<void> saveDailySteps(DailyStepsModel model) async {
    await _box.put(model.dateKey, model);
  }

  /// Get step record for a specific date
  DailyStepsModel? getDailySteps(DateTime date) {
    final key = _formatDateKey(date);
    return _box.get(key);
  }

  /// Get today's step record, or create a new one with defaults
  DailyStepsModel getTodaySteps(int dailyGoal) {
    final now = DateTime.now();
    final key = _formatDateKey(now);
    return _box.get(key) ??
        DailyStepsModel(
          date: now,
          steps: 0,
          goal: dailyGoal,
          caloriesBurned: 0,
          distanceKm: 0,
          activeMinutes: 0,
        );
  }

  /// Get last N days of step data (sorted oldest → newest)
  List<DailyStepsModel> getLastNDays(int days) {
    final results = <DailyStepsModel>[];
    final now = DateTime.now();

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = _formatDateKey(date);
      final record = _box.get(key);
      if (record != null) {
        results.add(record);
      } else {
        // Return zero-step placeholder for missing days
        results.add(DailyStepsModel(
          date: date,
          steps: 0,
          goal: AppConstants.defaultDailyGoal,
          caloriesBurned: 0,
          distanceKm: 0,
          activeMinutes: 0,
        ));
      }
    }
    return results;
  }

  /// Get all stored step records
  List<DailyStepsModel> getAllSteps() {
    return _box.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Total lifetime steps across all stored records
  int get totalLifetimeSteps =>
      _box.values.fold(0, (sum, model) => sum + model.steps);

  String _formatDateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

/// Global provider for the steps repository
final stepsRepositoryProvider = StepsRepository();
