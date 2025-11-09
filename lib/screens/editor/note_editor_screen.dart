import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../cubits/notes_bloc.dart';
import '../../cubits/notes_event.dart';
import '../../cubits/notes_state.dart';
import '../../models/notes_model.dart';
import '../../services/note_editor_service.dart';
import '../../widgets/attachments_list.dart';
import '../../widgets/category_selector.dart';
import '../../widgets/tag_input_field.dart';

class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({super.key, this.noteId});

  final int? noteId;

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final NoteEditorService _service;
  late final QuillController _quillController;
  late final TextEditingController _titleController;
  final FocusNode _editorFocusNode = FocusNode();

  bool _isLoading = true;
  String _category = '';
  List<String> _tags = [];
  List<Attachment> _attachments = [];
  bool _isPinned = false;

  List<String> _availableCategories = [];
  List<String> _availableTags = [];

  @override
  void initState() {
    super.initState();
    _service = NoteEditorService();
    _titleController = TextEditingController();
    _quillController = QuillController.basic();
    _loadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final categories = await _service.getAllCategories();
      final tags = await _service.getAllTags();

      setState(() {
        _availableCategories = [
          'Work',
          'Personal',
          'Ideas',
          'Study',
          ...categories,
        ];
        _availableTags = tags;
      });

      if (widget.noteId != null) {
        final note = await _service.loadNote(widget.noteId!);
        if (note != null && mounted) {
          setState(() {
            _titleController.text = note.title;
            _category = note.category;
            _tags = List.from(note.tags);
            _attachments = List.from(note.attachments);
            _isPinned = note.isPinned;
          });

          // Load content into Quill
          if (note.content.isNotEmpty) {
            try {
              final doc = Document.fromJson(jsonDecode(note.content));
              _quillController.document = doc;
            } catch (e) {
              // If content is not JSON, treat as plain text
              _quillController.document = _service.quillDocumentFromPlainText(
                note.content,
              );
            }
          }
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showSnackBar('Please enter a title', isError: true);
      return;
    }

    // Convert Quill document to JSON string
    final content = jsonEncode(_quillController.document.toDelta().toJson());

    if (widget.noteId != null) {
      // Update existing note
      context.read<NotesBloc>().add(
            UpdateNote(
              noteId: widget.noteId!,
              title: title,
              content: content,
              category: _category,
              tags: _tags,
              attachments: _attachments,
              isPinned: _isPinned,
            ),
          );
    } else {
      // Create new note
      context.read<NotesBloc>().add(
            CreateNote(
              title: title,
              content: content,
              category: _category,
              tags: _tags,
              attachments: _attachments,
              isPinned: _isPinned,
            ),
          );
    }
  }

  void _deleteNote() async {
    if (widget.noteId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text(
          'Are you sure you want to delete this note? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<NotesBloc>().add(DeleteNote(widget.noteId!));
    }
  }

  Future<void> _addAttachments() async {
    final newAttachments = await _service.pickFiles();
    if (newAttachments.isNotEmpty) {
      setState(() {
        _attachments.addAll(newAttachments);
      });
    }
  }

  void _removeAttachment(Attachment attachment) {
    setState(() {
      _attachments.remove(attachment);
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<NotesBloc, NotesState>(
      listener: (context, state) {
        if (state is NoteSaved) {
          _showSnackBar(state.message);
          Navigator.pop(context, true); // Return true when note is saved
        } else if (state is NoteDeleted) {
          _showSnackBar(state.message);
          Navigator.pop(context, true); // Return true when note is deleted (also a change)
        } else if (state is NotesError) {
          _showSnackBar(state.message, isError: true);
        }
      },
      builder: (context, state) {
        final isSaving = state is NotesOperationInProgress;

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: theme.scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              widget.noteId == null ? 'New Note' : 'Edit Note',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(_isPinned ? Icons.push_pin : Icons.push_pin_outlined),
                onPressed: () {
                  setState(() {
                    _isPinned = !_isPinned;
                  });
                },
                color: _isPinned ? theme.colorScheme.primary : null,
                tooltip: _isPinned ? 'Unpin note' : 'Pin note',
              ),
              if (widget.noteId != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _deleteNote,
                  color: theme.colorScheme.error,
                ),
              const SizedBox(width: 8),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Field
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Note title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.dividerColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),

                  // Category Selector
                  CategorySelector(
                    selectedCategory: _category,
                    availableCategories: _availableCategories,
                    onCategoryChanged: (category) {
                      setState(() => _category = category);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Content Editor
                  Text(
                    'Content',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        QuillSimpleToolbar(controller: _quillController ,
                          config: const QuillSimpleToolbarConfig(
                          showBoldButton: true,
                          showItalicButton: true,
                          showStrikeThrough: false,
                          showColorButton: true,
                          showBackgroundColorButton: false,
                          showListCheck: true,
                          showListBullets: true,
                          showListNumbers: true,
                          showAlignmentButtons: false,
                          showLeftAlignment: false,
                          showRightAlignment: false,
                          showCenterAlignment: false,
                          showJustifyAlignment: false,
                          showCodeBlock: false,
                          showQuote: true,
                          showIndent: false,
                          showInlineCode: false,
                          showFontSize: false,
                          showFontFamily: false,
                          showHeaderStyle: false,
                          showLink: false,
                          showUndo: true,
                          showRedo: true,
                          ),
                        ),
                        const Divider(height: 1),
                        Container(
                          constraints: const BoxConstraints(minHeight: 200),
                          padding: const EdgeInsets.all(16),
                          child: QuillEditor.basic(
                            controller: _quillController,
                            focusNode: _editorFocusNode,
                            config: const QuillEditorConfig(
                              padding: EdgeInsets.zero,
                              placeholder: 'Start writing your note...',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tags
                  Text(
                    'Tags',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TagInputField(
                    tags: _tags,
                    onTagsChanged: (tags) => setState(() => _tags = tags),
                    availableTags: _availableTags,
                  ),
                  const SizedBox(height: 16),

                  // Attachments
                  AttachmentsList(
                    attachments: _attachments,
                    onRemove: _removeAttachment,
                    onAdd: _addAttachments,
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: isSaving ? null : _saveNote,
            icon: isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save),
            label: Text(isSaving ? 'Saving...' : 'Save Note'),
            elevation: 4,
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }
}
