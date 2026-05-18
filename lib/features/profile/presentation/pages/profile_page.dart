import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../features/settings/data/models/user_profile_model.dart';
import '../../../../features/steps/data/repositories/steps_repository.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/widgets/app_cards.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../widgets/bmi_card.dart';
import '../widgets/body_info_card.dart';
import '../widgets/profile_header.dart';
import '../widgets/settings_tile.dart';
import '../widgets/stats_overview.dart';

/// Provider for the user's profile
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfileModel>((ref) {
  return UserProfileNotifier();
});

class UserProfileNotifier extends StateNotifier<UserProfileModel> {
  UserProfileNotifier() : super(UserProfileModel.defaultProfile);

  void updateProfile(UserProfileModel updated) {
    state = updated;
  }
}

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalSteps = stepsRepositoryProvider.totalLifetimeSteps;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Profile App Bar ───
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: ProfileHeader(profile: profile, isDark: isDark),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: Colors.white,
                ),
                onPressed: () =>
                    ref.read(themeModeProvider.notifier).toggle(),
              ),
              const SizedBox(width: 8),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),

                // ─── Stats Overview ───
                StatsOverview(profile: profile, totalSteps: totalSteps)
                    .animate()
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 24),

                // ─── Body Info Card ───
                SectionHeader(title: 'Body Information'),
                const SizedBox(height: 12),
                BodyInfoCard(profile: profile)
                    .animate()
                    .fadeIn(delay: 100.ms)
                    .slideY(begin: 0.2),

                const SizedBox(height: 24),

                // ─── BMI Card ───
                BmiCard(bmi: profile.bmi, category: profile.bmiCategory)
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .slideY(begin: 0.2),

                const SizedBox(height: 24),

                // ─── Settings Tiles ───
                SectionHeader(title: 'Settings'),
                const SizedBox(height: 12),
                SettingsTile(
                  icon: Icons.notifications_rounded,
                  label: 'Notifications',
                  color: AppColors.accentOrange,
                  trailing: Switch.adaptive(
                    value: true,
                    onChanged: (_) {},
                    activeColor: AppColors.primary,
                  ),
                ).animate().fadeIn(delay: 250.ms),
                const SizedBox(height: 8),
                SettingsTile(
                  icon: isDark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  label: 'Dark Mode',
                  color: AppColors.primary,
                  trailing: Switch.adaptive(
                    value: isDark,
                    onChanged: (_) =>
                        ref.read(themeModeProvider.notifier).toggle(),
                    activeColor: AppColors.primary,
                  ),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 8),
                const SettingsTile(
                  icon: Icons.privacy_tip_rounded,
                  label: 'Privacy Policy',
                  color: AppColors.accentBlue,
                  trailing: Icon(Icons.chevron_right_rounded,
                      color: AppColors.textSecondaryLight),
                ).animate().fadeIn(delay: 350.ms),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

