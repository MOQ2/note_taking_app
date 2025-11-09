import 'package:equatable/equatable.dart';
import '../models/notes_model.dart';

class SearchFilters extends Equatable {
  final String category;
  final String sortBy;
  final bool showPinnedOnly;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const SearchFilters({
    this.category = 'All',
    this.sortBy = 'Recent',
    this.showPinnedOnly = false,
    this.dateFrom,
    this.dateTo,
  });

  SearchFilters copyWith({
    String? category,
    String? sortBy,
    bool? showPinnedOnly,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool clearDateFrom = false,
    bool clearDateTo = false,
  }) {
    return SearchFilters(
      category: category ?? this.category,
      sortBy: sortBy ?? this.sortBy,
      showPinnedOnly: showPinnedOnly ?? this.showPinnedOnly,
      dateFrom: clearDateFrom ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDateTo ? null : (dateTo ?? this.dateTo),
    );
  }

  bool get hasActiveFilters {
    return category != 'All' || 
           showPinnedOnly || 
           sortBy != 'Recent' || 
           dateFrom != null || 
           dateTo != null;
  }

  @override
  List<Object?> get props => [category, sortBy, showPinnedOnly, dateFrom, dateTo];
}

abstract class SearchState extends Equatable {
  final SearchFilters filters;
  final String query;
  
  const SearchState({
    this.filters = const SearchFilters(),
    this.query = '',
  });

  @override
  List<Object?> get props => [filters, query];
}

class SearchInitial extends SearchState {
  const SearchInitial({super.filters, super.query});
}

class SearchLoading extends SearchState {
  const SearchLoading({super.filters, super.query});
}

class SearchResults extends SearchState {
  final List<Note> results;

  const SearchResults(this.results, {super.filters, super.query});

  @override
  List<Object?> get props => [results, query, filters];
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message, {super.filters, super.query});

  @override
  List<Object?> get props => [message, filters, query];
}
