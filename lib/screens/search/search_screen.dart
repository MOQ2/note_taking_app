import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/search_bloc.dart';
import '../../cubits/search_event.dart';
import '../../cubits/search_state.dart';
import '../../models/notes_model.dart';
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            final filters = state.filters;
            String tempCategory = filters.category;
            String tempSortBy = filters.sortBy;
            bool tempShowPinnedOnly = filters.showPinnedOnly;
            DateTime? tempDateFrom = filters.dateFrom;
            DateTime? tempDateTo = filters.dateTo;

            return StatefulBuilder(
              builder: (context, setDialogState) {
                return AlertDialog(
                  title: const Text('Filter & Sort'),
                  contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Filter
                        Text(
                          'Category',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Wrap(
                          spacing: 8,
                          children: _categoryOptions.map((category) {
                            final isSelected = tempCategory == category;
                            return FilterChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                setDialogState(() {
                                  tempCategory = selected ? category : 'All';
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        
                        // Sort Options
                        Text(
                          'Sort By',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: tempSortBy,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Recent', child: Text('Most Recent')),
                            DropdownMenuItem(value: 'Oldest', child: Text('Oldest First')),
                            DropdownMenuItem(value: 'Title A-Z', child: Text('Title (A-Z)')),
                            DropdownMenuItem(value: 'Title Z-A', child: Text('Title (Z-A)')),
                          ],
                          onChanged: (value) {
                            setDialogState(() {
                              tempSortBy = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Pinned Only Filter
                        CheckboxListTile(
                          title: const Text('Show Pinned Only'),
                          contentPadding: EdgeInsets.zero,
                          value: tempShowPinnedOnly,
                          onChanged: (value) {
                            setDialogState(() {
                              tempShowPinnedOnly = value ?? false;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        
                        // Date Range Filter
                        Text(
                          'Date Range',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.calendar_today, size: 16),
                                label: Text(
                                  tempDateFrom == null 
                                    ? 'From' 
                                    : '${tempDateFrom!.month}/${tempDateFrom!.day}/${tempDateFrom!.year}',
                                ),
                                onPressed: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: tempDateFrom ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                  );
                                  if (date != null) {
                                    setDialogState(() {
                                      tempDateFrom = date;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.calendar_today, size: 16),
                                label: Text(
                                  tempDateTo == null 
                                    ? 'To' 
                                    : '${tempDateTo!.month}/${tempDateTo!.day}/${tempDateTo!.year}',
                                ),
                                onPressed: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: tempDateTo ?? DateTime.now(),
                                    firstDate: tempDateFrom ?? DateTime(2020),
                                    lastDate: DateTime.now(),
                                  );
                                  if (date != null) {
                                    setDialogState(() {
                                      tempDateTo = date;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        if (tempDateFrom != null || tempDateTo != null)
                          TextButton(
                            onPressed: () {
                              setDialogState(() {
                                tempDateFrom = null;
                                tempDateTo = null;
                              });
                            },
                            child: const Text('Clear Dates'),
                          ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        context.read<SearchBloc>().add(const ResetSearchFilters());
                        Navigator.pop(context);
                      },
                      child: const Text('Reset'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () {
                        context.read<SearchBloc>().add(
                          UpdateSearchFilters(
                            category: tempCategory,
                            sortBy: tempSortBy,
                            showPinnedOnly: tempShowPinnedOnly,
                            dateFrom: tempDateFrom,
                            dateTo: tempDateTo,
                          ),
                        );
                        Navigator.pop(context);
                        // Re-trigger search to apply filters
                        if (_searchController.text.trim().isNotEmpty) {
                          _onSearchChanged(_searchController.text);
                        }
                      },
                      child: const Text('Apply'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
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
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
                          color: _colorForCategory(note.category).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          note.category,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _colorForCategory(note.category),
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

  Color _colorForCategory(String category) {
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
