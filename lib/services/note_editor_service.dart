import 'package:flutter_quill/flutter_quill.dart';
import 'package:file_picker/file_picker.dart';

import '../models/notes_model.dart';
import '../repositories/notes_repository.dart';

class NoteEditorService {
  NoteEditorService({NotesRepository? notesRepository})
    : _notesRepository = notesRepository ?? NotesRepository();

  final NotesRepository _notesRepository;

  Future<Note?> loadNote(int noteId) async {
    return _notesRepository.getNoteById(noteId);
  }

  Future<int> saveNote({
    int? noteId,
    required String title,
    required String content,
    required String category,
    required List<String> tags,
    required List<Attachment> attachments,
    required bool isPinned,
  }) async {
    final now = DateTime.now();

    if (noteId != null) {
      // Update existing note
      final existingNote = await _notesRepository.getNoteById(noteId);
      if (existingNote != null) {
        existingNote
          ..title = title
          ..content = content
          ..category = category
          ..tags = tags
          ..attachments = attachments
          ..isPinned = isPinned
          ..updatedAt = now;
        return _notesRepository.updateNote(existingNote);
      }
    }

    // Create new note
    final newNote = Note(
      title: title,
      content: content,
      category: category,
      tags: tags,
      attachments: attachments,
      isPinned: isPinned,
      createdAt: now,
      updatedAt: now,
    );

    return _notesRepository.createNote(newNote);
  }

  Future<bool> deleteNote(int noteId) async {
    return _notesRepository.deleteNote(noteId);
  }

  Future<List<String>> getAllCategories() async {
    return _notesRepository.getAllCategories();
  }

  Future<List<String>> getAllTags() async {
    return _notesRepository.getAllTags();
  }

  Future<List<Attachment>> pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result == null || result.files.isEmpty) {
        return [];
      }

      return result.files.map((file) {
        return Attachment(title: file.name, path: file.path ?? '');
      }).toList();
    } catch (e) {
      return [];
    }
  }

  String plainTextFromQuill(Document document) {
    return document.toPlainText().trim();
  }

  Document quillDocumentFromPlainText(String text) {
    if (text.isEmpty) {
      return Document();
    }
    return Document()..insert(0, text);
  }
}
