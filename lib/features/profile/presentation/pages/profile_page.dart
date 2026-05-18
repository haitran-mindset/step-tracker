import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../features/settings/data/models/user_profile_model.dart';
import '../../../../features/steps/data/repositories/steps_repository.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/widgets/app_cards.dart';
import '../../../../shared/widgets/common_widgets.dart';

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
              background: _ProfileHeader(profile: profile, isDark: isDark),
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
                _StatsOverview(profile: profile, totalSteps: totalSteps)
                    .animate()
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 24),

                // ─── Body Info Card ───
                SectionHeader(title: 'Body Information'),
                const SizedBox(height: 12),
                _BodyInfoCard(profile: profile)
                    .animate()
                    .fadeIn(delay: 100.ms)
                    .slideY(begin: 0.2),

                const SizedBox(height: 24),

                // ─── BMI Card ───
                _BmiCard(bmi: profile.bmi, category: profile.bmiCategory)
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .slideY(begin: 0.2),

                const SizedBox(height: 24),

                // ─── Settings Tiles ───
                SectionHeader(title: 'Settings'),
                const SizedBox(height: 12),
                _SettingsTile(
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
                _SettingsTile(
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
                _SettingsTile(
                  icon: Icons.privacy_tip_rounded,
                  label: 'Privacy Policy',
                  color: AppColors.accentBlue,
                  trailing: const Icon(Icons.chevron_right_rounded,
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

// ──────────────────── Profile Header ────────────────────

class _ProfileHeader extends StatelessWidget {
  final UserProfileModel profile;
  final bool isDark;

  const _ProfileHeader({required this.profile, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // Avatar
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 50,
              ),
            )
                .animate()
                .scale(begin: const Offset(0.5, 0.5), duration: 500.ms)
                .fadeIn(),

            const SizedBox(height: 12),

            Text(
              profile.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),

            const SizedBox(height: 4),

            Text(
              'Fitness Enthusiast',
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 14,
              ),
            ).animate().fadeIn(delay: 150.ms),
          ],
        ),
      ),
    );
  }
}

// ──────────────────── Stats Overview ────────────────────

class _StatsOverview extends StatelessWidget {
  final UserProfileModel profile;
  final int totalSteps;

  const _StatsOverview({required this.profile, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        _StatChip(
          value: '$totalSteps',
          label: 'Lifetime Steps',
          icon: Icons.directions_walk_rounded,
          color: AppColors.primary,
          isDark: isDark,
        ),
        const SizedBox(width: 12),
        _StatChip(
          value: '${(totalSteps * 0.762 / 1000).toStringAsFixed(0)} km',
          label: 'Total Distance',
          icon: Icons.route_rounded,
          color: AppColors.secondary,
          isDark: isDark,
        ),
        const SizedBox(width: 12),
        _StatChip(
          value: '${(totalSteps * 0.04).toStringAsFixed(0)}',
          label: 'kcal Burned',
          icon: Icons.local_fire_department_rounded,
          color: AppColors.accentOrange,
          isDark: isDark,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatChip({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────── Body Info Card ────────────────────

class _BodyInfoCard extends StatelessWidget {
  final UserProfileModel profile;

  const _BodyInfoCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return NeumorphicCard(
      child: Column(
        children: [
          _InfoRow(
            label: 'Height',
            value: '${profile.height.toStringAsFixed(0)} cm',
            icon: Icons.height_rounded,
          ),
          const Divider(height: 24),
          _InfoRow(
            label: 'Weight',
            value: '${profile.weight.toStringAsFixed(1)} kg',
            icon: Icons.monitor_weight_rounded,
          ),
          const Divider(height: 24),
          _InfoRow(
            label: 'Age',
            value: '${profile.age} years',
            icon: Icons.cake_rounded,
          ),
          const Divider(height: 24),
          _InfoRow(
            label: 'Gender',
            value: _capitalize(profile.gender),
            icon: Icons.person_rounded,
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 14),
        Text(
          label,
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}

// ──────────────────── BMI Card ────────────────────

class _BmiCard extends StatelessWidget {
  final double bmi;
  final String category;

  const _BmiCard({required this.bmi, required this.category});

  Color _bmiColor() {
    if (bmi < 18.5) return AppColors.accentBlue;
    if (bmi < 25.0) return AppColors.secondary;
    if (bmi < 30.0) return AppColors.accentOrange;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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

// ──────────────────── Settings Tile ────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Widget trailing;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
