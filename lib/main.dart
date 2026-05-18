import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/data/models/user_profile_model.dart';
import 'features/steps/data/models/daily_steps_model.dart';
import 'shared/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(UserProfileModelAdapter());
  Hive.registerAdapter(DailyStepsModelAdapter());

  // Open Hive boxes
  await Hive.openBox<UserProfileModel>(AppConstants.userProfileBox);
  await Hive.openBox<DailyStepsModel>(AppConstants.stepsBox);
  await Hive.openBox(AppConstants.settingsBox);

  // Initialize notifications
  await NotificationService.instance.initialize();

  runApp(
    const ProviderScope(
      child: StepTrackerApp(),
    ),
  );
}

class StepTrackerApp extends ConsumerWidget {
  const StepTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'StepTracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
