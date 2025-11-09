import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchNotes extends SearchEvent {
  final String query;

  const SearchNotes(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearch extends SearchEvent {
  const ClearSearch();
}

class UpdateSearchFilters extends SearchEvent {
  final String? category;
  final String? sortBy;
  final bool? showPinnedOnly;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const UpdateSearchFilters({
    this.category,
    this.sortBy,
    this.showPinnedOnly,
    this.dateFrom,
    this.dateTo,
  });

  @override
  List<Object?> get props => [category, sortBy, showPinnedOnly, dateFrom, dateTo];
}

class ResetSearchFilters extends SearchEvent {
  const ResetSearchFilters();
}
