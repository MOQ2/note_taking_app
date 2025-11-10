import 'package:flutter/material.dart';

class CategoryColors {
  CategoryColors._();

  /// Get the color associated with a category
  static Color getCategoryColor(String category, BuildContext context) {
    final theme = Theme.of(context);
    final key = category.toLowerCase();
    switch (key) {
      case 'work':
        return Colors.orange;
      case 'personal':
        return Colors.green;
      case 'ideas':
        return Colors.indigo;
      case 'study':
        return Colors.blue;
      case 'health':
        return Colors.redAccent;
      case 'travel':
        return Colors.teal;
      case 'finance':
        return Colors.deepPurple;
      default:
        return theme.colorScheme.primary;
    }
  }
}
