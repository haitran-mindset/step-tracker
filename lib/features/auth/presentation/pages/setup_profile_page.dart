import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/data/services/firestore_user_service.dart';
import '../../../profile/presentation/providers/user_profile_provider.dart';

class SetupProfilePage extends ConsumerStatefulWidget {
  const SetupProfilePage({super.key});

  @override
  ConsumerState<SetupProfilePage> createState() => _SetupProfilePageState();
}

class _SetupProfilePageState extends ConsumerState<SetupProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();

  String _selectedGender = 'male';
  bool _isLoading = false;
  int _currentStep = 0;

  static const _genders = [
    ('male', Icons.male_rounded, 'Male'),
    ('female', Icons.female_rounded, 'Female'),
    ('other', Icons.person_rounded, 'Other'),
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill fields with existing profile data if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileAsync = ref.read(firestoreUserProfileProvider);
      profileAsync.whenData((data) {
        if (data != null) {
          setState(() {
            _nameController.text = data['name'] as String? ?? '';
            _heightController.text = data['height']?.toString() ?? '';
            _weightController.text = data['weight']?.toString() ?? '';
            _ageController.text = data['age']?.toString() ?? '';
            _selectedGender = data['gender'] as String? ?? 'male';
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      await FirestoreUserService.instance.updateUserProfile(user.uid, {
        'uid': user.uid,
        'email': user.email,
        'name': _nameController.text.trim(),
        'height': double.parse(_heightController.text),
        'weight': double.parse(_weightController.text),
        'age': int.parse(_ageController.text),
        'gender': _selectedGender,
        'profileComplete': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Force Riverpod to refresh the user profile stream immediately
      ref.invalidate(firestoreUserProfileProvider);

      if (mounted) {
        if (Navigator.of(context).canPop()) {
          context.pop();
        } else {
          context.go('/dashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorExtension>()!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textPrimary),
                onPressed: () => context.pop(),
              )
            : IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textPrimary),
                onPressed: () => context.go('/dashboard'),
              ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // ─── Header ───
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Column(
                children: [
                  Icon(
                    Icons.person_pin_rounded,
                      size: 56,
                      color: theme.colorScheme.primary,
                    ).animate().scale(duration: 400.ms),
                    const SizedBox(height: 16),
                    Text(
                      'Set Up Your Profile',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 8),
                    Text(
                      'Help us personalize your fitness experience',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ).animate().fadeIn(delay: 150.ms),
                    const SizedBox(height: 24),
                    // Step indicator
                    _StepIndicator(current: _currentStep, total: 2),
                  ],
                ),
              ),

              // ─── Steps ───
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.1, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _currentStep == 0
                        ? _StepOne(
                            key: const ValueKey('step0'),
                            nameController: _nameController,
                            ageController: _ageController,
                            selectedGender: _selectedGender,
                            genders: _genders,
                            onGenderChanged: (g) =>
                                setState(() => _selectedGender = g),
                          )
                        : _StepTwo(
                            key: const ValueKey('step1'),
                            heightController: _heightController,
                            weightController: _weightController,
                          ),
                  ),
                ),
              ),

              // ─── Bottom Buttons ───
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              setState(() => _currentStep--),
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Back'),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (_currentStep == 0) {
                                  // Validate step 0 fields
                                  if (_nameController.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content:
                                          Text('Please enter your name'),
                                    ));
                                    return;
                                  }
                                  if (_ageController.text.isEmpty) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content:
                                          Text('Please enter your age'),
                                    ));
                                    return;
                                  }
                                  setState(() => _currentStep++);
                                } else {
                                  _saveProfile();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _currentStep == 0
                                    ? 'Continue'
                                    : 'Get Started',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }
}

// ─── Step Indicator ───
class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;

  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i <= current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == current ? 28 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: isActive
                ? primary
                : primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }
}

// ─── Step 1: Name, Age, Gender ───
class _StepOne extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController ageController;
  final String selectedGender;
  final List<(String, IconData, String)> genders;
  final ValueChanged<String> onGenderChanged;

  const _StepOne({
    super.key,
    required this.nameController,
    required this.ageController,
    required this.selectedGender,
    required this.genders,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorExtension>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tell us about yourself',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),

        // Name field
        _buildLabel(context, 'Full Name'),
        const SizedBox(height: 8),
        _buildTextField(
          context,
          controller: nameController,
          hint: 'e.g. Hai Tran',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 20),

        // Age field
        _buildLabel(context, 'Age'),
        const SizedBox(height: 8),
        _buildTextField(
          context,
          controller: ageController,
          hint: 'e.g. 25',
          icon: Icons.cake_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 20),

        // Gender selector
        _buildLabel(context, 'Gender'),
        const SizedBox(height: 12),
        Row(
          children: genders.map((g) {
            final (value, icon, label) = g;
            final isSelected = selectedGender == value;
            return Expanded(
              child: GestureDetector(
                onTap: () => onGenderChanged(value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : colors.cardGradientStart,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : colors.textSecondary.withOpacity(0.15),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        icon,
                        color: isSelected
                            ? Colors.white
                            : colors.textSecondary,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? Colors.white
                              : colors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── Step 2: Height, Weight ───
class _StepTwo extends StatelessWidget {
  final TextEditingController heightController;
  final TextEditingController weightController;

  const _StepTwo({
    super.key,
    required this.heightController,
    required this.weightController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorExtension>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your body metrics',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Used to calculate your BMI and calorie estimates',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),

        // Height
        _buildLabel(context, 'Height (cm)'),
        const SizedBox(height: 8),
        _buildTextField(
          context,
          controller: heightController,
          hint: 'e.g. 170',
          icon: Icons.height_rounded,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}'))
          ],
          suffix: 'cm',
        ),
        const SizedBox(height: 20),

        // Weight
        _buildLabel(context, 'Weight (kg)'),
        const SizedBox(height: 8),
        _buildTextField(
          context,
          controller: weightController,
          hint: 'e.g. 65',
          icon: Icons.monitor_weight_outlined,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}'))
          ],
          suffix: 'kg',
        ),

        const SizedBox(height: 24),

        // Info card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'This data is stored securely and only used to personalize your fitness stats.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Shared helpers ───
Widget _buildLabel(BuildContext context, String text) {
  return Text(
    text,
    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context)
              .extension<AppColorExtension>()!
              .textSecondary,
          fontWeight: FontWeight.w600,
        ),
  );
}

Widget _buildTextField(
  BuildContext context, {
  required TextEditingController controller,
  required String hint,
  required IconData icon,
  TextInputType keyboardType = TextInputType.text,
  List<TextInputFormatter>? inputFormatters,
  String? suffix,
}) {
  final theme = Theme.of(context);
  final colors = theme.extension<AppColorExtension>()!;

  return TextField(
    controller: controller,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    style: theme.textTheme.bodyLarge?.copyWith(color: colors.textPrimary),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: theme.textTheme.bodyLarge
          ?.copyWith(color: colors.textSecondary.withOpacity(0.4)),
      prefixIcon: Icon(icon, color: colors.textSecondary, size: 20),
      suffixText: suffix,
      suffixStyle: theme.textTheme.bodyMedium
          ?.copyWith(color: colors.textSecondary),
      filled: true,
      fillColor: colors.cardGradientStart,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: colors.textSecondary.withOpacity(0.1),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: theme.colorScheme.primary,
          width: 1.5,
        ),
      ),
    ),
  );
}
