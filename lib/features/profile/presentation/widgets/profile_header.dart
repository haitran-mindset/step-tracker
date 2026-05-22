import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../features/settings/data/models/user_profile_model.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfileModel profile;
  final bool isDark;
  final String? email;

  const ProfileHeader({
    super.key,
    required this.profile,
    required this.isDark,
    this.email,
  });

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

            if (email != null)
              Text(
                email!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 13,
                ),
              ).animate().fadeIn(delay: 130.ms),

            const SizedBox(height: 4),

            Text(
              'Keep Walking, Keep Growing.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
              ),
            ).animate().fadeIn(delay: 150.ms),
          ],
        ),
      ),
    );
  }
}
