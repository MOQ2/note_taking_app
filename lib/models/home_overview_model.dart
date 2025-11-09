import 'package:flutter/material.dart';
import 'notes_model.dart';

class CategorySummary {
  const CategorySummary({
    required this.name,
    required this.noteCount,
    this.icon,
  });

  final String name;
  final int noteCount;
  final IconData? icon;
}

class HomeOverviewData {
  const HomeOverviewData({
    required this.pinnedNotes,
    required this.categorySummaries,
    required this.recentNotes,
  });

  final List<Note> pinnedNotes;
  final List<CategorySummary> categorySummaries;
  final List<Note> recentNotes;

  bool get hasPinnedNotes => pinnedNotes.isNotEmpty;
  bool get hasCategories => categorySummaries.isNotEmpty;
  bool get hasRecentNotes => recentNotes.isNotEmpty;
}
