import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/step_counter_provider.dart';
import '../../../../shared/widgets/app_cards.dart';
import '../../../../shared/widgets/common_widgets.dart';

class SetGoalSection extends ConsumerStatefulWidget {
  final int currentGoal;
  const SetGoalSection({super.key, required this.currentGoal});

  @override
  ConsumerState<SetGoalSection> createState() => _SetGoalSectionState();
}

class _SetGoalSectionState extends ConsumerState<SetGoalSection> {
  late int _selected;
  static const _presets = [5000, 7500, 10000, 12500, 15000];

  @override
  void initState() {
    super.initState();
    _selected = widget.currentGoal;
  }

  @override
  Widget build(BuildContext context) {
    return NeumorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Set Daily Goal'),
          const SizedBox(height: 16),

          // Preset chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presets.map((p) {
              final isSelected = _selected == p;
              return ChoiceChip(
                label: Text(_formatSteps(p)),
                selected: isSelected,
                onSelected: (_) {
                  setState(() => _selected = p);
                  HapticFeedback.lightImpact();
                  ref.read(dailyGoalProvider.notifier).setGoal(p);
                },
                selectedColor: AppColors.primary,
                backgroundColor:
                    Theme.of(context).brightness == Brightness.dark
                        ? AppColors.surfaceDark
                        : const Color(0xFFF0F1FF),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected
                        ? Colors.transparent
                        : AppColors.primary.withOpacity(0.2),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Custom goal slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.primary.withOpacity(0.2),
              thumbColor: Colors.white,
              overlayColor: AppColors.primary.withOpacity(0.15),
            ),
            child: Slider(
              min: 1000,
              max: 20000,
              divisions: 38,
              value: _selected.toDouble(),
              onChanged: (v) {
                setState(() => _selected = v.round());
              },
              onChangeEnd: (v) {
                ref.read(dailyGoalProvider.notifier).setGoal(v.round());
                HapticFeedback.selectionClick();
              },
            ),
          ),

          Center(
            child: Text(
              _formatSteps(_selected),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatSteps(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k steps';
    return '$n steps';
  }
}
