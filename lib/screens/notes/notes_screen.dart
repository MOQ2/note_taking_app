import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/notes_bloc.dart';
import '../../cubits/notes_event.dart';
import '../../cubits/notes_state.dart';
import '../../models/notes_model.dart';
import '../editor/note_editor_screen.dart';
import '../note_detail/note_detail_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  bool _isGridView = false;
  String _selectedCategory = 'All';
  String _sortBy = 'Recent'; // Recent, Oldest, Title A-Z, Title Z-A
  bool _showPinnedOnly = false;

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
    // Load all notes when screen initializes
    context.read<NotesBloc>().add(const LoadNotes());
  }

  void _handleRefresh() {
    context.read<NotesBloc>().add(const LoadNotes());
  }

  List<Note> _filterAndSortNotes(List<Note> notes) {
    var filtered = notes;

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((note) => note.category == _selectedCategory).toList();
    }

    // Filter pinned only
    if (_showPinnedOnly) {
      filtered = filtered.where((note) => note.isPinned).toList();
    }

    // Sort
    switch (_sortBy) {
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
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
                    final isSelected = _selectedCategory == category;
                    return FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setDialogState(() {
                          _selectedCategory = selected ? category : 'All';
                        });
                        setState(() {
                          _selectedCategory = selected ? category : 'All';
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
                  value: _sortBy,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'Recent', child: Text('Most Recent')),
                    DropdownMenuItem(
                        value: 'Oldest', child: Text('Oldest First')),
                    DropdownMenuItem(
                        value: 'Title A-Z', child: Text('Title (A-Z)')),
                    DropdownMenuItem(
                        value: 'Title Z-A', child: Text('Title (Z-A)')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      _sortBy = value!;
                    });
                    setState(() {
                      _sortBy = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Pinned Only Filter
                CheckboxListTile(
                  title: const Text('Show Pinned Only'),
                  contentPadding: EdgeInsets.zero,
                  value: _showPinnedOnly,
                  onChanged: (value) {
                    setDialogState(() {
                      _showPinnedOnly = value ?? false;
                    });
                    setState(() {
                      _showPinnedOnly = value ?? false;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = 'All';
                  _sortBy = 'Recent';
                  _showPinnedOnly = false;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Reset'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Notes'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            tooltip: _isGridView ? 'List View' : 'Grid View',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter & Sort',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _handleRefresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NoteEditorScreen()),
          );
          if (mounted) {
            _handleRefresh();
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Create Note',
      ),
      body: BlocBuilder<NotesBloc, NotesState>(
        builder: (context, state) {
          if (state is NotesLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is NotesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading notes',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _handleRefresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is NotesLoaded) {
            final notes = _filterAndSortNotes(state.notes);

            if (notes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.note_outlined,
                      size: 80,
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.notes.isEmpty ? 'No notes yet' : 'No notes match your filters',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.notes.isEmpty 
                          ? 'Tap the + button to create your first note'
                          : 'Try adjusting your filters',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                _handleRefresh();
              },
              child: _isGridView
                  ? _buildGridView(notes, theme)
                  : _buildListView(notes, theme),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildGridView(List<Note> notes, ThemeData theme) {
    return GridView.builder(
      key: const PageStorageKey('notes_grid_view'),
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return _buildNoteCard(note, theme, isGrid: true);
      },
    );
  }

  Widget _buildListView(List<Note> notes, ThemeData theme) {
    return ListView.builder(
      key: const PageStorageKey('notes_list_view'),
      padding: const EdgeInsets.all(8.0),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return _buildNoteCard(note, theme, isGrid: false);
      },
    );
  }

  Widget _buildNoteCard(Note note, ThemeData theme, {required bool isGrid}) {
    final content = note.getFormattedContent(maxLength: isGrid ? 80 : 120);
    final hasCategory = note.category.isNotEmpty;
    final hasTags = note.tags.isNotEmpty;

    return Card(
      elevation: 2,
      margin: isGrid ? EdgeInsets.zero : const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteDetailScreen(noteId: note.id),
            ),
          );
          if (mounted) {
            _handleRefresh();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and pin icon
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: isGrid ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (note.isPinned)
                    Icon(
                      Icons.push_pin,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Content preview
              Text(
                content,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: isGrid ? 4 : 2,
                overflow: TextOverflow.ellipsis,
              ),
              //if (isGrid) const Spacer(),

              // Category and tags
              if (hasCategory || hasTags) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    if (hasCategory)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          note.category,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ...note.tags.take(isGrid ? 2 : 3).map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tag,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              ],

              // Date
              const SizedBox(height: 8),
              Text(
                _formatDate(note.updatedAt),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else {
      return '${(difference.inDays / 365).floor()}y ago';
    }
  }
}
