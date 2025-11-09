import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/notes_model.dart';
import '../services/home_notes_service.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final HomeNotesService _notesService;

  SearchBloc({
    HomeNotesService? notesService,
  })  : _notesService = notesService ?? HomeNotesService(),
        super(const SearchInitial()) {
    on<SearchNotes>(_onSearchNotes);
    on<ClearSearch>(_onClearSearch);
    on<UpdateSearchFilters>(_onUpdateSearchFilters);
    on<ResetSearchFilters>(_onResetSearchFilters);
  }

  Future<void> _onSearchNotes(
      SearchNotes event, Emitter<SearchState> emit) async {
    if (event.query.trim().isEmpty) {
      emit(SearchInitial(filters: state.filters, query: ''));
      return;
    }

    emit(SearchLoading(filters: state.filters, query: event.query));
    try {
      final results = await _notesService.searchNotes(event.query);
      final filteredResults = _applyFilters(results, state.filters);
      emit(SearchResults(filteredResults, filters: state.filters, query: event.query));
    } catch (e) {
      emit(SearchError('Failed to search notes: $e', filters: state.filters, query: event.query));
    }
  }

  Future<void> _onClearSearch(
      ClearSearch event, Emitter<SearchState> emit) async {
    emit(SearchInitial(filters: state.filters, query: ''));
  }

  Future<void> _onUpdateSearchFilters(
      UpdateSearchFilters event, Emitter<SearchState> emit) async {
    final newFilters = state.filters.copyWith(
      category: event.category,
      sortBy: event.sortBy,
      showPinnedOnly: event.showPinnedOnly,
      dateFrom: event.dateFrom,
      dateTo: event.dateTo,
      clearDateFrom: event.dateFrom == null && event.dateFrom != state.filters.dateFrom,
      clearDateTo: event.dateTo == null && event.dateTo != state.filters.dateTo,
    );

    // If we have a current query, re-apply filters to existing results
    if (state.query.isNotEmpty && state is SearchResults) {
      // Re-fetch and filter with new filters to ensure consistency
      try {
        final results = await _notesService.searchNotes(state.query);
        final filteredResults = _applyFilters(results, newFilters);
        emit(SearchResults(filteredResults, filters: newFilters, query: state.query));
      } catch (e) {
        emit(SearchError('Failed to apply filters: $e', filters: newFilters, query: state.query));
      }
    } else {
      emit(SearchInitial(filters: newFilters, query: state.query));
    }
  }

  Future<void> _onResetSearchFilters(
      ResetSearchFilters event, Emitter<SearchState> emit) async {
    const newFilters = SearchFilters();
    
    // If we have a current query, re-apply with reset filters
    if (state.query.isNotEmpty && state is SearchResults) {
      try {
        final results = await _notesService.searchNotes(state.query);
        final filteredResults = _applyFilters(results, newFilters);
        emit(SearchResults(filteredResults, filters: newFilters, query: state.query));
      } catch (e) {
        emit(SearchError('Failed to reset filters: $e', filters: newFilters, query: state.query));
      }
    } else {
      emit(SearchInitial(filters: newFilters, query: state.query));
    }
  }

  List<Note> _applyFilters(List<Note> notes, SearchFilters filters) {
    List<Note> filtered = notes;
    
    // Filter by category
    if (filters.category != 'All') {
      filtered = filtered.where((note) => 
        note.category.toLowerCase() == filters.category.toLowerCase()
      ).toList();
    }
    
    // Filter by pinned status
    if (filters.showPinnedOnly) {
      filtered = filtered.where((note) => note.isPinned).toList();
    }
    
    // Filter by date range
    if (filters.dateFrom != null) {
      filtered = filtered.where((note) {
        return note.updatedAt.isAfter(filters.dateFrom!) || 
               note.updatedAt.isAtSameMomentAs(filters.dateFrom!);
      }).toList();
    }
    
    if (filters.dateTo != null) {
      final endOfDay = DateTime(
        filters.dateTo!.year, 
        filters.dateTo!.month, 
        filters.dateTo!.day, 
        23, 59, 59
      );
      filtered = filtered.where((note) {
        return note.updatedAt.isBefore(endOfDay) || 
               note.updatedAt.isAtSameMomentAs(endOfDay);
      }).toList();
    }
    
    // Sort results
    switch (filters.sortBy) {
      case 'Recent':
        filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case 'Oldest':
        filtered.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case 'Title A-Z':
        filtered.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case 'Title Z-A':
        filtered.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
    }
    
    return filtered;
  }
}
