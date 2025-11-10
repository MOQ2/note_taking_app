import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/search_bloc.dart';
import '../../cubits/search_event.dart';
import '../../cubits/search_state.dart';
import '../../models/notes_model.dart';
import '../../utils/category_colors.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/filter_dialog_widget.dart';
import '../../widgets/search_filter_bar.dart';
import '../note_detail/note_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  // Filter options
  final List<String> _categoryOptions = [
    'All',
    'Work',
    'Personal',
    'Ideas',
    'Study',
    'Health',
    'Travel',
    'Finance',
  ];

  @override
  void initState() {
    super.initState();
    // Auto-focus search field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      context.read<SearchBloc>().add(const ClearSearch());
    } else {
      context.read<SearchBloc>().add(SearchNotes(trimmed));
    }
  }

  void _showFilterDialog() async {
    final state = context.read<SearchBloc>().state;
    final filters = state.filters;

    final result = await showDialog<FilterDialogResult>(
      context: context,
      builder: (dialogContext) => FilterDialogWidget(
        config: FilterDialogConfig(
          selectedCategory: filters.category,
          sortBy: filters.sortBy,
          showPinnedOnly: filters.showPinnedOnly,
          dateFrom: filters.dateFrom,
          dateTo: filters.dateTo,
          categoryOptions: _categoryOptions,
          showDateFilter: true,
        ),
      ),
    );

    if (result != null && mounted) {
      if (result.wasReset) {
        context.read<SearchBloc>().add(const ResetSearchFilters());
      } else {
        context.read<SearchBloc>().add(
          UpdateSearchFilters(
            category: result.category,
            sortBy: result.sortBy,
            showPinnedOnly: result.showPinnedOnly,
            dateFrom: result.dateFrom,
            dateTo: result.dateTo,
          ),
        );
      }
      
      // Re-trigger search to apply filters
      if (_searchController.text.trim().isNotEmpty) {
        _onSearchChanged(_searchController.text);
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<SearchBloc>().add(const ClearSearch());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Search Notes'),
          elevation: 0,
          backgroundColor: theme.scaffoldBackgroundColor,
        ),
        body: Column(
        children: [
          SearchFilterBar(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: _onSearchChanged,
            onSubmitted: _onSearchChanged,
            onFilterTap: _showFilterDialog,
          ),
          // Display active filters as chips
          BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              final filters = state.filters;
              if (!filters.hasActiveFilters) {
                return const SizedBox.shrink();
              }
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (filters.category != 'All')
                      Chip(
                        label: Text(filters.category),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          context.read<SearchBloc>().add(
                            UpdateSearchFilters(category: 'All'),
                          );
                          if (_searchController.text.trim().isNotEmpty) {
                            _onSearchChanged(_searchController.text);
                          }
                        },
                      ),
                    if (filters.showPinnedOnly)
                      Chip(
                        label: const Text('Pinned Only'),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          context.read<SearchBloc>().add(
                            const UpdateSearchFilters(showPinnedOnly: false),
                          );
                          if (_searchController.text.trim().isNotEmpty) {
                            _onSearchChanged(_searchController.text);
                          }
                        },
                      ),
                    if (filters.sortBy != 'Recent')
                      Chip(
                        label: Text('Sort: ${filters.sortBy}'),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          context.read<SearchBloc>().add(
                            const UpdateSearchFilters(sortBy: 'Recent'),
                          );
                          if (_searchController.text.trim().isNotEmpty) {
                            _onSearchChanged(_searchController.text);
                          }
                        },
                      ),
                    if (filters.dateFrom != null || filters.dateTo != null)
                      Chip(
                        label: Text(
                          filters.dateFrom != null && filters.dateTo != null
                              ? '${filters.dateFrom!.month}/${filters.dateFrom!.day} - ${filters.dateTo!.month}/${filters.dateTo!.day}'
                              : filters.dateFrom != null
                                  ? 'From ${filters.dateFrom!.month}/${filters.dateFrom!.day}'
                                  : 'To ${filters.dateTo!.month}/${filters.dateTo!.day}',
                        ),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          context.read<SearchBloc>().add(
                            const UpdateSearchFilters(dateFrom: null, dateTo: null),
                          );
                          if (_searchController.text.trim().isNotEmpty) {
                            _onSearchChanged(_searchController.text);
                          }
                        },
                      ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (state is SearchLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is SearchResults) {
                  if (state.results.isEmpty) {
                    return _buildEmptySearchState(
                      'No notes found matching your search',
                      Icons.search_off,
                    );
                  }

                  return _buildSearchResults(state.results);
                }

                return _buildEmptySearchState(
                  'Start typing to search your notes',
                  Icons.search,
                );
              },
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildEmptySearchState(String message, IconData icon) {
    return EmptyStateWidget(
      icon: icon,
      title: message,
    );
  }

  Widget _buildSearchResults(List<Note> results) {
    final theme = Theme.of(context);
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final note = results[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              note.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  note.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (note.category.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: CategoryColors.getCategoryColor(note.category, context).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          note.category,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: CategoryColors.getCategoryColor(note.category, context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const Spacer(),
                    if (note.isPinned)
                      Icon(
                        Icons.push_pin,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                  ],
                ),
              ],
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteDetailScreen(noteId: note.id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
