import 'package:flutter_riverpod/flutter_riverpod.dart';

enum StatFilter { today, week, month }

final statFilterProvider = StateProvider<StatFilter>((ref) => StatFilter.week);
