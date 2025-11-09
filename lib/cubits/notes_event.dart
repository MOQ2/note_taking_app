import 'package:equatable/equatable.dart';
import '../models/notes_model.dart';

abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object?> get props => [];
}

/// Load all notes
class LoadNotes extends NotesEvent {
  const LoadNotes();
}

/// Load home overview data (pinned, categories, recent)
class LoadHomeOverview extends NotesEvent {
  const LoadHomeOverview();
}

/// Load a specific note by ID
class LoadNoteById extends NotesEvent {
  final int noteId;

  const LoadNoteById(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

/// Create a new note
class CreateNote extends NotesEvent {
  final String title;
  final String content;
  final String category;
  final List<String> tags;
  final List<Attachment> attachments;
  final bool isPinned;

  const CreateNote({
    required this.title,
    required this.content,
    this.category = '',
    this.tags = const [],
    this.attachments = const [],
    this.isPinned = false,
  });

  @override
  List<Object?> get props => [title, content, category, tags, attachments, isPinned];
}

/// Update an existing note
class UpdateNote extends NotesEvent {
  final int noteId;
  final String title;
  final String content;
  final String category;
  final List<String> tags;
  final List<Attachment> attachments;
  final bool isPinned;

  const UpdateNote({
    required this.noteId,
    required this.title,
    required this.content,
    this.category = '',
    this.tags = const [],
    this.attachments = const [],
    this.isPinned = false,
  });

  @override
  List<Object?> get props => [noteId, title, content, category, tags, attachments, isPinned];
}

/// Delete a note
class DeleteNote extends NotesEvent {
  final int noteId;

  const DeleteNote(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

/// Toggle pin status of a note
class TogglePinNote extends NotesEvent {
  final int noteId;

  const TogglePinNote(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

/// Search notes
class SearchNotes extends NotesEvent {
  final String query;

  const SearchNotes(this.query);

  @override
  List<Object?> get props => [query];
}

/// Clear search
class ClearSearch extends NotesEvent {
  const ClearSearch();
}

/// Get all categories
class LoadCategories extends NotesEvent {
  const LoadCategories();
}

/// Get all tags
class LoadTags extends NotesEvent {
  const LoadTags();
}
