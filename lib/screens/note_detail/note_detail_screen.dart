import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../cubits/notes_bloc.dart';
import '../../cubits/notes_event.dart';
import '../../cubits/notes_state.dart';
import '../editor/note_editor_screen.dart';

class NoteDetailScreen extends StatefulWidget {
  const NoteDetailScreen({super.key, required this.noteId});

  final int noteId;

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  bool _noteWasModified = false;

  @override
  void initState() {
    super.initState();
    context.read<NotesBloc>().add(LoadNoteById(widget.noteId));
  }

  void _togglePin() {
    _noteWasModified = true; // Mark as modified when pin is toggled
    context.read<NotesBloc>().add(TogglePinNote(widget.noteId));
  }

  void _deleteNote() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<NotesBloc>().add(DeleteNote(widget.noteId));
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = months[date.month - 1];
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$month $day, $year - $hour:$minute';
  }

  Color _getCategoryColor(String category) {
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
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<NotesBloc, NotesState>(
      listener: (context, state) {
        if (state is NoteDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          Navigator.pop(context, true); // Note was deleted (modified)
        } else if (state is NotePinToggled) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              duration: const Duration(seconds: 2),
            ),
          );
          // Reload the note to update the UI
          context.read<NotesBloc>().add(LoadNoteById(widget.noteId));
        } else if (state is NotesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is NotesLoading) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Loading...'),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is! NoteDetailLoaded) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Note Not Found'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Note not found',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This note may have been deleted',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        final note = state.note;

        // Parse Quill document
        Document? quillDocument;
        if (note.content.isNotEmpty) {
          try {
            final decoded = jsonDecode(note.content);
            quillDocument = Document.fromJson(decoded);
          } catch (e) {
            quillDocument = Document()..insert(0, note.content);
          }
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            // Return modification status when popping
            if (!didPop) {
              Navigator.of(context).pop(_noteWasModified);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Note Details'),
              actions: [
              IconButton(
                icon: Icon(note.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
                onPressed: _togglePin,
                tooltip: note.isPinned ? 'Unpin note' : 'Pin note',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: _deleteNote,
                tooltip: 'Delete note',
              ),
              const SizedBox(width: 8),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteEditorScreen(noteId: note.id),
                ),
              );
              if (result == true && mounted) {
                // Note was edited, mark as modified and reload
                _noteWasModified = true;
                context.read<NotesBloc>().add(LoadNoteById(widget.noteId));
              }
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  note.title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Metadata Row
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Category chip
                    if (note.category.isNotEmpty)
                      Chip(
                        avatar: Icon(
                          Icons.folder_outlined,
                          size: 16,
                          color: _getCategoryColor(note.category),
                        ),
                        label: Text(note.category),
                        backgroundColor: _getCategoryColor(note.category).withOpacity(0.1),
                        side: BorderSide(
                          color: _getCategoryColor(note.category).withOpacity(0.3),
                        ),
                      ),
                    
                    // Pin indicator
                    if (note.isPinned)
                      Chip(
                        avatar: const Icon(Icons.push_pin, size: 16),
                        label: const Text('Pinned'),
                        backgroundColor: theme.colorScheme.primaryContainer,
                      ),
                  ],
                ),

                // Tags
                if (note.tags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: note.tags.map((tag) {
                  return Chip(
                    label: Text('#$tag'),
                    labelStyle: theme.textTheme.bodySmall,
                    backgroundColor: theme.colorScheme.secondaryContainer.withOpacity(0.5),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 24),

            // Date Information
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Created: ${_formatDate(note.createdAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.update,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Updated: ${_formatDate(note.updatedAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Divider
            const Divider(),
            const SizedBox(height: 24),

            // Content Label
            Text(
              'Content',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Content - Read-only Quill Editor
            if (quillDocument != null)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(16),
                child: QuillEditor.basic(
                  controller: QuillController(
                    document: quillDocument,
                    selection: const TextSelection.collapsed(offset: 0),
                    readOnly: true,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'No content',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            // Attachments
            if (note.attachments.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Attachments',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...(note.attachments.map((attachment) {
                return ListTile(
                  leading: const Icon(Icons.attach_file),
                  title: Text(attachment.title),
                  subtitle: Text(attachment.path),
                  contentPadding: EdgeInsets.zero,
                );
              })),
            ],

                // Bottom padding for FAB
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
        );
      },
    );
  }
}
