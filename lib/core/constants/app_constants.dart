class AppConstants {
  AppConstants._();

  // Hive box names
  static const String userProfileBox = 'user_profile_box';
  static const String stepsBox = 'daily_steps_box';
  static const String settingsBox = 'settings_box';

  // Settings keys
  static const String themeModeKey = 'theme_mode';
  static const String dailyGoalKey = 'daily_goal';
  static const String notificationsKey = 'notifications_enabled';
  static const String onboardingKey = 'onboarding_complete';

  // Default values
  static const int defaultDailyGoal = 10000;
  static const double defaultHeight = 170.0; // cm
  static const double defaultWeight = 70.0;  // kg
  static const double strideLength = 0.762;  // meters (avg stride)

  // Notification IDs
  static const int goalAchievedNotifId = 1001;
  static const int dailyReminderNotifId = 1002;

  // Durations
  static const Duration animationDuration = Duration(milliseconds: 600);
  static const Duration shortAnimation = Duration(milliseconds: 300);

  // Chart constants
  static const int weekDays = 7;
  static const int monthDays = 30;
}
