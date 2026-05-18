class NumberFormatter {
  /// Formats a number to a compact string (e.g., 12.5k)
  static String formatSteps(num n) {
    if (n >= 1000) {
      double value = n / 1000;
      return '${value == value.toInt() ? value.toInt() : value.toStringAsFixed(1)}k';
    }
    return n.toInt().toString();
  }
}
