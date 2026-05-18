import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/stat_filter_provider.dart';

class FilterChips extends ConsumerWidget {
  final StatFilter selected;
  const FilterChips({super.key, required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: StatFilter.values.map((f) {
        final isSelected = f == selected;
        final label = f.name[0].toUpperCase() + f.name.substring(1);

        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            child: FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) =>
                  ref.read(statFilterProvider.notifier).state = f,
              selectedColor: AppColors.primary,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.cardDark
                  : AppColors.cardLight,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : null,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
              side: BorderSide(
                color: isSelected ? Colors.transparent : AppColors.primary.withOpacity(0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
