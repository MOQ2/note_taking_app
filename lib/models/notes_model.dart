import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart';
import 'package:isar/isar.dart';

part 'notes_model.g.dart';

@collection
class Note {
  Id id = Isar.autoIncrement;

  @Index()
  late String title;

  late String content;

  late DateTime createdAt;

  late DateTime updatedAt;

  @Index()
  List<String> tags = [];

  List<Attachment> attachments = [];

  late String category;

  @Index()
  bool isPinned = false;

  Note({
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.attachments = const [],
    this.category = '',
    this.isPinned = false,
  });

  String get summary {
    return getFormattedContent(maxLength: 100);
  }

  /// Get plain text from Quill JSON content
  String getFormattedContent({int? maxLength}) {
    if (content.isEmpty) {
      return 'No content';
    }

    try {
      final decoded = jsonDecode(content);
      final document = Document.fromJson(decoded);
      final plainText = document.toPlainText().trim();
      
      if (plainText.isEmpty) {
        return 'No content';
      }

      if (maxLength != null && plainText.length > maxLength) {
        return '${plainText.substring(0, maxLength)}...';
      }

      return plainText;
    } catch (e) {
      // If it's not valid JSON, return as plain text
      if (maxLength != null && content.length > maxLength) {
        return '${content.substring(0, maxLength)}...';
      }
      return content;
    }
  }
}

@embedded
class Attachment {
  late String title;
  late String path;

  Attachment({this.title = '', this.path = ''});
}
