import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/notes_model.dart';
import '../repositories/notes_repository.dart';
import '../services/home_notes_service.dart';
import 'notes_event.dart';
import 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NotesRepository _repository;
  final HomeNotesService _homeService;

  NotesBloc({
    NotesRepository? repository,
    HomeNotesService? homeService,
  })  : _repository = repository ?? NotesRepository(),
        _homeService = homeService ?? HomeNotesService(),
        super(const NotesInitial()) {
    on<LoadNotes>(_onLoadNotes);
    on<LoadHomeOverview>(_onLoadHomeOverview);
    on<LoadNoteById>(_onLoadNoteById);
    on<CreateNote>(_onCreateNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
    on<TogglePinNote>(_onTogglePinNote);
    on<SearchNotes>(_onSearchNotes);
    on<ClearSearch>(_onClearSearch);
    on<LoadCategories>(_onLoadCategories);
    on<LoadTags>(_onLoadTags);
  }

  Future<void> _onLoadNotes(LoadNotes event, Emitter<NotesState> emit) async {
    emit(const NotesLoading());
    try {
      final notes = await _repository.getAllNotes();
      emit(NotesLoaded(notes));
    } catch (e) {
      emit(NotesError('Failed to load notes: $e'));
    }
  }

  Future<void> _onLoadHomeOverview(
      LoadHomeOverview event, Emitter<NotesState> emit) async {
    emit(const NotesLoading());
    try {
      final overview = await _homeService.loadHomeOverview();
      emit(HomeOverviewLoaded(overview));
    } catch (e) {
      emit(NotesError('Failed to load home overview: $e'));
    }
  }

  Future<void> _onLoadNoteById(
      LoadNoteById event, Emitter<NotesState> emit) async {
    emit(const NotesLoading());
    try {
      final note = await _repository.getNoteById(event.noteId);
      if (note != null) {
        emit(NoteDetailLoaded(note));
      } else {
        emit(const NotesError('Note not found'));
      }
    } catch (e) {
      emit(NotesError('Failed to load note: $e'));
    }
  }

  Future<void> _onCreateNote(CreateNote event, Emitter<NotesState> emit) async {
    emit(const NotesOperationInProgress());
    try {
      final note = Note(
        title: event.title,
        content: event.content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        category: event.category,
        tags: event.tags,
        attachments: event.attachments,
        isPinned: event.isPinned,
      );
      final noteId = await _repository.createNote(note);
      emit(NoteSaved(noteId));
    } catch (e) {
      emit(NotesError('Failed to create note: $e'));
    }
  }

  Future<void> _onUpdateNote(UpdateNote event, Emitter<NotesState> emit) async {
    emit(const NotesOperationInProgress());
    try {
      // First load the existing note to preserve the ID and createdAt
      final existingNote = await _repository.getNoteById(event.noteId);
      if (existingNote == null) {
        emit(const NotesError('Note not found'));
        return;
      }

      final note = Note(
        title: event.title,
        content: event.content,
        createdAt: existingNote.createdAt,
        updatedAt: DateTime.now(),
        category: event.category,
        tags: event.tags,
        attachments: event.attachments,
        isPinned: event.isPinned,
      )..id = event.noteId;

      await _repository.updateNote(note);
      emit(NoteSaved(event.noteId));
    } catch (e) {
      emit(NotesError('Failed to update note: $e'));
    }
  }

  Future<void> _onDeleteNote(DeleteNote event, Emitter<NotesState> emit) async {
    emit(const NotesOperationInProgress());
    try {
      final success = await _repository.deleteNote(event.noteId);
      if (success) {
        emit(const NoteDeleted());
      } else {
        emit(const NotesError('Failed to delete note'));
      }
    } catch (e) {
      emit(NotesError('Failed to delete note: $e'));
    }
  }

  Future<void> _onTogglePinNote(
      TogglePinNote event, Emitter<NotesState> emit) async {
    try {
      final note = await _repository.getNoteById(event.noteId);
      if (note == null) {
        emit(const NotesError('Note not found'));
        return;
      }

      final updatedNote = Note(
        title: note.title,
        content: note.content,
        createdAt: note.createdAt,
        updatedAt: DateTime.now(),
        tags: note.tags,
        attachments: note.attachments,
        category: note.category,
        isPinned: !note.isPinned,
      )..id = note.id;

      await _repository.updateNote(updatedNote);
      emit(NotePinToggled(event.noteId, updatedNote.isPinned));
    } catch (e) {
      emit(NotesError('Failed to toggle pin: $e'));
    }
  }

  Future<void> _onSearchNotes(
      SearchNotes event, Emitter<NotesState> emit) async {
    try {
      if (event.query.trim().isEmpty) {
        emit(const NotesSearchResults([], ''));
        return;
      }

      final results = await _homeService.searchNotes(event.query);
      emit(NotesSearchResults(results, event.query));
    } catch (e) {
      emit(NotesError('Failed to search notes: $e'));
    }
  }

  Future<void> _onClearSearch(
      ClearSearch event, Emitter<NotesState> emit) async {
    emit(const NotesSearchResults([], ''));
  }

  Future<void> _onLoadCategories(
      LoadCategories event, Emitter<NotesState> emit) async {
    try {
      final categories = await _repository.getAllCategories();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(NotesError('Failed to load categories: $e'));
    }
  }

  Future<void> _onLoadTags(LoadTags event, Emitter<NotesState> emit) async {
    try {
      final tags = await _repository.getAllTags();
      emit(TagsLoaded(tags));
    } catch (e) {
      emit(NotesError('Failed to load tags: $e'));
    }
  }
}
