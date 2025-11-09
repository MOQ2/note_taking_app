import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/notes_model.dart';

class NotesRepository {
  static Isar? _isar;

  // Initialize Isar database
  Future<Isar> _getIsar() async {
    if (_isar != null && _isar!.isOpen) {
      return _isar!;
    }

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [NoteSchema],
      directory: dir.path,
    );
    return _isar!;
  }

  // Create a new note
  Future<int> createNote(Note note) async {
    final isar = await _getIsar();
    return await isar.writeTxn(() async {
      return await isar.notes.put(note);
    });
  }

  // Get all notes
  Future<List<Note>> getAllNotes() async {
    final isar = await _getIsar();
    return await isar.notes.where().findAll();
  }

  // Get note by ID
  Future<Note?> getNoteById(int id) async {
    final isar = await _getIsar();
    return await isar.notes.get(id);
  }

  // Update a note
  Future<int> updateNote(Note note) async {
    final isar = await _getIsar();
    note.updatedAt = DateTime.now();
    return await isar.writeTxn(() async {
      return await isar.notes.put(note);
    });
  }

  // Delete a note
  Future<bool> deleteNote(int id) async {
    final isar = await _getIsar();
    return await isar.writeTxn(() async {
      return await isar.notes.delete(id);
    });
  }

  // Delete multiple notes
  Future<int> deleteNotes(List<int> ids) async {
    final isar = await _getIsar();
    return await isar.writeTxn(() async {
      return await isar.notes.deleteAll(ids);
    });
  }

  // Search notes by title
  Future<List<Note>> searchNotesByTitle(String query) async {
    final isar = await _getIsar();
    return await isar.notes
        .filter()
        .titleContains(query, caseSensitive: false)
        .findAll();
  }

  // Search notes by content
  Future<List<Note>> searchNotesByContent(String query) async {
    final isar = await _getIsar();
    return await isar.notes
        .filter()
        .contentContains(query, caseSensitive: false)
        .findAll();
  }

  // Get notes by category
  Future<List<Note>> getNotesByCategory(String category) async {
    final isar = await _getIsar();
    return await isar.notes.filter().categoryEqualTo(category).findAll();
  }

  // Get notes by tag
  Future<List<Note>> getNotesByTag(String tag) async {
    final isar = await _getIsar();
    return await isar.notes
        .filter()
        .tagsElementContains(tag, caseSensitive: false)
        .findAll();
  }

  // Get notes sorted by creation date (newest first)
  Future<List<Note>> getNotesSortedByDateDesc() async {
    final isar = await _getIsar();
    return await isar.notes.where().sortByCreatedAtDesc().findAll();
  }

  // Get notes sorted by creation date (oldest first)
  Future<List<Note>> getNotesSortedByDateAsc() async {
    final isar = await _getIsar();
    return await isar.notes.where().sortByCreatedAt().findAll();
  }

  // Get notes sorted by title
  Future<List<Note>> getNotesSortedByTitle() async {
    final isar = await _getIsar();
    return await isar.notes.where().sortByTitle().findAll();
  }

  // Get notes sorted by last updated
  Future<List<Note>> getNotesSortedByUpdatedDesc() async {
    final isar = await _getIsar();
    return await isar.notes.where().sortByUpdatedAtDesc().findAll();
  }

  // Get recent notes (last n notes)
  Future<List<Note>> getRecentNotes(int limit) async {
    final isar = await _getIsar();
    return await isar.notes
        .where()
        .sortByCreatedAtDesc()
        .limit(limit)
        .findAll();
  }

  // Get all unique categories
  Future<List<String>> getAllCategories() async {
    final isar = await _getIsar();
    final notes = await isar.notes.where().findAll();
    final categories = notes.map((note) => note.category).toSet().toList();
    categories.removeWhere((cat) => cat.isEmpty);
    return categories;
  }

  // Get all unique tags
  Future<List<String>> getAllTags() async {
    final isar = await _getIsar();
    final notes = await isar.notes.where().findAll();
    final tags = <String>{};
    for (var note in notes) {
      tags.addAll(note.tags);
    }
    return tags.toList();
  }

  // Get count of all notes
  Future<int> getNotesCount() async {
    final isar = await _getIsar();
    return await isar.notes.count();
  }

  // Get count by category
  Future<int> getCountByCategory(String category) async {
    final isar = await _getIsar();
    return await isar.notes.filter().categoryEqualTo(category).count();
  }

  // Watch all notes (Stream for real-time updates)
  Stream<List<Note>> watchAllNotes() async* {
    final isar = await _getIsar();
    yield* isar.notes.where().watch(fireImmediately: true);
  }

  // Watch specific note by ID
  Stream<Note?> watchNote(int id) async* {
    final isar = await _getIsar();
    yield* isar.notes.watchObject(id, fireImmediately: true);
  }

  // Batch create notes
  Future<List<int>> createNotes(List<Note> notes) async {
    final isar = await _getIsar();
    return await isar.writeTxn(() async {
      return await isar.notes.putAll(notes);
    });
  }

  // Clear all notes (use with caution!)
  Future<void> clearAllNotes() async {
    final isar = await _getIsar();
    await isar.writeTxn(() async {
      await isar.notes.clear();
    });
  }

  // Close Isar instance
  Future<void> close() async {
    if (_isar != null && _isar!.isOpen) {
      await _isar!.close();
      _isar = null;
    }
  }

  // Get notes with attachments
  Future<List<Note>> getNotesWithAttachments() async {
    final isar = await _getIsar();
    final allNotes = await isar.notes.where().findAll();
    return allNotes.where((note) => note.attachments.isNotEmpty).toList();
  }

  // Advanced search (title, content, tags, category)
  Future<List<Note>> advancedSearch(String query) async {
    final isar = await _getIsar();
    return await isar.notes
        .filter()
        .group(
          (q) => q
              .titleContains(query, caseSensitive: false)
              .or()
              .contentContains(query, caseSensitive: false)
              .or()
              .categoryContains(query, caseSensitive: false)
              .or()
              .tagsElementContains(query, caseSensitive: false),
        )
        .findAll();
  }
}
