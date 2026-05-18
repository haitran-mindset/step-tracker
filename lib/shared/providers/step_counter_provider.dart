import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/notification_service.dart';
import '../../features/steps/data/models/daily_steps_model.dart';
import '../../features/steps/data/repositories/steps_repository.dart';

// ──────────────────── Goal Provider ────────────────────

/// Persisted daily step goal
final dailyGoalProvider = StateNotifierProvider<DailyGoalNotifier, int>((ref) {
  return DailyGoalNotifier();
});

class DailyGoalNotifier extends StateNotifier<int> {
  DailyGoalNotifier() : super(AppConstants.defaultDailyGoal) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt(AppConstants.dailyGoalKey) ?? AppConstants.defaultDailyGoal;
  }

  Future<void> setGoal(int goal) async {
    state = goal;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.dailyGoalKey, goal);
  }
}

// ──────────────────── Step Counter Provider ────────────────────

/// Holds the live state of the step counter
class StepCounterState {
  final int steps;
  final bool isWalking;
  final bool goalAchieved;
  final bool permissionGranted;
  final String? errorMessage;

  const StepCounterState({
    this.steps = 0,
    this.isWalking = false,
    this.goalAchieved = false,
    this.permissionGranted = true,
    this.errorMessage,
  });

  StepCounterState copyWith({
    int? steps,
    bool? isWalking,
    bool? goalAchieved,
    bool? permissionGranted,
    String? errorMessage,
  }) {
    return StepCounterState(
      steps: steps ?? this.steps,
      isWalking: isWalking ?? this.isWalking,
      goalAchieved: goalAchieved ?? this.goalAchieved,
      permissionGranted: permissionGranted ?? this.permissionGranted,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final stepCounterProvider =
    StateNotifierProvider<StepCounterNotifier, StepCounterState>((ref) {
  final goal = ref.watch(dailyGoalProvider);
  return StepCounterNotifier(goal: goal, ref: ref);
});

class StepCounterNotifier extends StateNotifier<StepCounterState> {
  final int goal;
  final Ref ref;

  StreamSubscription<StepCount>? _stepSub;
  StreamSubscription<PedestrianStatus>? _statusSub;

  // Baseline step count from sensor to track only today's steps
  int? _baseline;
  bool _goalNotified = false;

  StepCounterNotifier({required this.goal, required this.ref})
      : super(const StepCounterState()) {
    _init();
  }

  Future<void> _init() async {
    final repo = stepsRepositoryProvider;
    final today = repo.getTodaySteps(goal);

    // Restore today's stored steps so we don't lose data on restart
    state = state.copyWith(steps: today.steps);

    try {
      // Listen to pedestrian status (walking/stopped)
      _statusSub = Pedometer.pedestrianStatusStream.listen(
        _onPedestrianStatus,
        onError: (_) => state = state.copyWith(isWalking: false),
      );

      // Listen to hardware step count sensor
      _stepSub = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: (e) => state = state.copyWith(
          errorMessage: 'Pedometer error: $e',
          permissionGranted: false,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Pedometer unavailable',
        permissionGranted: false,
      );
      // Fall back to using stored data
      _useMockData();
    }
  }

  void _onStepCount(StepCount event) {
    // First reading → set baseline
    _baseline ??= event.steps - state.steps;

    final todaySteps = (event.steps - _baseline!).clamp(0, 9999999);
    _updateSteps(todaySteps);
  }

  void _onPedestrianStatus(PedestrianStatus event) {
    state = state.copyWith(isWalking: event.status == 'walking');
  }

  void _updateSteps(int steps) {
    final goalAchieved = steps >= goal;
    state = state.copyWith(steps: steps, goalAchieved: goalAchieved);

    // Fire goal notification once per day
    if (goalAchieved && !_goalNotified) {
      _goalNotified = true;
      NotificationService.instance.showGoalAchievedNotification(steps);
    }

    // Persist to Hive
    _persistToday(steps);
  }

  Future<void> _persistToday(int steps) async {
    final repo = stepsRepositoryProvider;
    final weight = 70.0; // will be fetched from profile in a real app
    final calories = steps * 0.04 * (weight / 70);
    final distanceKm = steps * AppConstants.strideLength / 1000;
    final activeMinutes = (steps / 100).round().clamp(0, 1440);

    final model = DailyStepsModel(
      date: DateTime.now(),
      steps: steps,
      goal: goal,
      caloriesBurned: calories,
      distanceKm: distanceKm,
      activeMinutes: activeMinutes,
    );
    await repo.saveDailySteps(model);
  }

  /// Simulate steps in dev/simulator environments
  void _useMockData() {
    final repo = stepsRepositoryProvider;
    final today = repo.getTodaySteps(goal);
    _updateSteps(today.steps > 0 ? today.steps : 4230);
  }

  /// Manually add steps (for testing)
  void addSteps(int count) => _updateSteps(state.steps + count);

  @override
  void dispose() {
    _stepSub?.cancel();
    _statusSub?.cancel();
    super.dispose();
  }
}

// ──────────────────── Today Stats Provider ────────────────────

final todayStatsProvider = Provider<DailyStepsModel>((ref) {
  final stepState = ref.watch(stepCounterProvider);
  final goal = ref.watch(dailyGoalProvider);
  final weight = 70.0;

  final steps = stepState.steps;
  final calories = steps * 0.04 * (weight / 70);
  final distanceKm = steps * AppConstants.strideLength / 1000;
  final activeMinutes = (steps / 100).round().clamp(0, 1440);

  return DailyStepsModel(
    date: DateTime.now(),
    steps: steps,
    goal: goal,
    caloriesBurned: calories,
    distanceKm: distanceKm,
    activeMinutes: activeMinutes,
  );
});
