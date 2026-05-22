import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/settings/data/models/user_profile_model.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/bmi_card.dart';
import '../widgets/body_info_card.dart';
import '../widgets/profile_header.dart';
import '../widgets/settings_tile.dart';
import '../widgets/stats_overview.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final firestoreProfile = ref.watch(firestoreUserProfileProvider);

    // Build a UserProfileModel from Firestore data (or fallback to placeholder)
    final profile = firestoreProfile.when(
      data: (data) {
        debugPrint("FIRESTORE PROFILE DATA: $data");
        if (data == null || data['name'] == null) {
          debugPrint("FIRESTORE DATA IS NULL OR NAME IS NULL");
          return null;
        }
        return UserProfileModel(
          id: data['uid'] as String? ?? firebaseUser?.uid ?? 'unknown',
          name: data['name'] as String,
          height: (data['height'] as num?)?.toDouble() ?? 170.0,
          weight: (data['weight'] as num?)?.toDouble() ?? 65.0,
          age: data['age'] as int? ?? 25,
          gender: data['gender'] as String? ?? 'other',
          totalLifetimeSteps: data['totalLifetimeSteps'] as int? ?? 0,
          createdAt: (data['createdAt'] != null)
              ? (data['createdAt'] as dynamic).toDate()
              : DateTime.now(),
        );
      },
      loading: () {
        debugPrint("FIRESTORE PROFILE LOADING...");
        return null;
      },
      error: (err, stack) {
        debugPrint("FIRESTORE PROFILE ERROR: $err");
        debugPrint(stack.toString());
        return null;
      },
    );

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
              background: ProfileHeader(
                profile: profile ?? UserProfileModel.defaultProfile,
                isDark: isDark,
                email: firebaseUser?.email,
              ),
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

                // ─── Loading indicator or Profile Banner or Profile Details ───
                if (firestoreProfile.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (profile == null)
                  _IncompleteProfileBanner()
                else ...[
                  // ─── Stats Overview ───
                  StatsOverview(profile: profile!, totalSteps: 0)
                      .animate()
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 24),

                  // ─── Body Info Card ───
                  SectionHeader(title: 'Body Information'),
                  const SizedBox(height: 12),
                  BodyInfoCard(profile: profile!)
                      .animate()
                      .fadeIn(delay: 100.ms)
                      .slideY(begin: 0.2),

                  const SizedBox(height: 24),

                  // ─── BMI Card ───
                  BmiCard(bmi: profile!.bmi, category: profile!.bmiCategory)
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .slideY(begin: 0.2),
                ],

                const SizedBox(height: 24),

                // ─── Settings Tiles (Always Visible) ───
                SectionHeader(title: 'Settings'),
                const SizedBox(height: 12),
                if (profile != null) ...[
                  SettingsTile(
                    icon: Icons.person_outline_rounded,
                    label: 'Edit Profile',
                    color: AppColors.primary,
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textSecondaryLight),
                    onTap: () => context.push('/setup-profile'),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 8),
                ],
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

                // ─── Account / Logout — always visible ───
                const SizedBox(height: 24),
                SectionHeader(title: 'Account'),
                const SizedBox(height: 12),
                _LogoutTile().animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoutTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.error.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: authState.isLoading
            ? null
            : () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Sign Out'),
                    content:
                        const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref.read(authNotifierProvider.notifier).logout();
                }
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: authState.isLoading
                    ? Padding(
                        padding: const EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.error,
                        ),
                      )
                    : Icon(
                        Icons.logout_rounded,
                        color: theme.colorScheme.error,
                        size: 22,
                      ),
              ),
              const SizedBox(width: 14),
              Text(
                'Sign Out',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IncompleteProfileBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(
            Icons.person_add_alt_1_rounded,
            size: 56,
            color: theme.colorScheme.primary.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Profile Not Set Up',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your profile to see your stats',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Theme.of(context)
                  .extension<AppColorExtension>()!
                  .textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => context.push('/setup-profile'),
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text('Complete Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
