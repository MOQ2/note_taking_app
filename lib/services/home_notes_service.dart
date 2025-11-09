import 'dart:collection';

import 'package:flutter/material.dart';

import '../models/home_overview_model.dart';
import '../models/notes_model.dart';
import '../repositories/notes_repository.dart';

class HomeNotesService {
  HomeNotesService({NotesRepository? notesRepository})
    : _notesRepository = notesRepository ?? NotesRepository();

  final NotesRepository _notesRepository;

  Future<HomeOverviewData> loadHomeOverview({
    int pinnedLimit = 5,
    int recentLimit = 6,
  }) async {
    final pinnedNotes = await _resolvePinnedNotes(limit: pinnedLimit);
    final categorySummaries = await _resolveCategorySummaries();
    final recentNotes = await _notesRepository.getRecentNotes(recentLimit);

    return HomeOverviewData(
      pinnedNotes: pinnedNotes,
      categorySummaries: categorySummaries,
      recentNotes: recentNotes,
    );
  }

  Future<List<Note>> searchNotes(String query) async {
    if (query.trim().isEmpty) {
      return const [];
    }
    return _notesRepository.advancedSearch(query.trim());
  }

  Future<List<Note>> _resolvePinnedNotes({required int limit}) async {
    final allNotes = await _notesRepository.getAllNotes();
    final pinned =
        allNotes.where((note) => note.isPinned).toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return pinned.take(limit).toList(growable: false);
  }

  Future<List<CategorySummary>> _resolveCategorySummaries() async {
    final categories = await _notesRepository.getAllCategories();
    if (categories.isEmpty) {
      return const [];
    }

    final summaries = <CategorySummary>[];
    for (final category in categories) {
      final count = await _notesRepository.getCountByCategory(category);
      summaries.add(
        CategorySummary(
          name: category,
          noteCount: count,
          icon: _iconForCategory(category),
        ),
      );
    }

    summaries.sort((a, b) => b.noteCount.compareTo(a.noteCount));
    return UnmodifiableListView(summaries);
  }

  IconData? _iconForCategory(String rawCategory) {
    final key = rawCategory.toLowerCase().trim();
    if (key.isEmpty) {
      return Icons.note_outlined;
    }

    const iconMap = <String, IconData>{
      'work': Icons.work_outline,
      'personal': Icons.home_outlined,
      'ideas': Icons.lightbulb_outline,
      'study': Icons.book_outlined,
      'learning': Icons.school_outlined,
      'health': Icons.favorite_border,
      'travel': Icons.flight_takeoff,
      'finance': Icons.attach_money,
      'shopping': Icons.shopping_cart_outlined,
      'journal': Icons.menu_book,
    };

    return iconMap[key] ?? Icons.folder_open;
  }
}
