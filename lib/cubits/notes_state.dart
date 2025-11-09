import 'package:equatable/equatable.dart';
import '../models/home_overview_model.dart';
import '../models/notes_model.dart';

abstract class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class NotesInitial extends NotesState {
  const NotesInitial();
}

/// Loading state
class NotesLoading extends NotesState {
  const NotesLoading();
}

/// Notes loaded successfully
class NotesLoaded extends NotesState {
  final List<Note> notes;

  const NotesLoaded(this.notes);

  @override
  List<Object?> get props => [notes];
}

/// Home overview loaded
class HomeOverviewLoaded extends NotesState {
  final HomeOverviewData overview;

  const HomeOverviewLoaded(this.overview);

  @override
  List<Object?> get props => [overview];
}

/// Single note loaded
class NoteDetailLoaded extends NotesState {
  final Note note;

  const NoteDetailLoaded(this.note);

  @override
  List<Object?> get props => [note];
}

/// Note saved successfully
class NoteSaved extends NotesState {
  final int noteId;
  final String message;

  const NoteSaved(this.noteId, {this.message = 'Note saved successfully'});

  @override
  List<Object?> get props => [noteId, message];
}

/// Note deleted successfully
class NoteDeleted extends NotesState {
  final String message;

  const NoteDeleted({this.message = 'Note deleted successfully'});

  @override
  List<Object?> get props => [message];
}

/// Note pinned/unpinned
class NotePinToggled extends NotesState {
  final int noteId;
  final bool isPinned;
  final String message;

  const NotePinToggled(this.noteId, this.isPinned, {String? message})
      : message = message ?? (isPinned ? 'Note pinned' : 'Note unpinned');

  @override
  List<Object?> get props => [noteId, isPinned, message];
}

/// Search results
class NotesSearchResults extends NotesState {
  final List<Note> results;
  final String query;

  const NotesSearchResults(this.results, this.query);

  @override
  List<Object?> get props => [results, query];
}

/// Categories loaded
class CategoriesLoaded extends NotesState {
  final List<String> categories;

  const CategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

/// Tags loaded
class TagsLoaded extends NotesState {
  final List<String> tags;

  const TagsLoaded(this.tags);

  @override
  List<Object?> get props => [tags];
}

/// Error state
class NotesError extends NotesState {
  final String message;

  const NotesError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Operation in progress
class NotesOperationInProgress extends NotesState {
  const NotesOperationInProgress();
}
