import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart';

class QuillHelper {
  /// Extracts plain text from Quill JSON content
  static String getPlainTextFromQuillJson(String jsonContent) {
    if (jsonContent.isEmpty) {
      return '';
    }

    try {
      final decoded = jsonDecode(jsonContent);
      final document = Document.fromJson(decoded);
      return document.toPlainText().trim();
    } catch (e) {
      // If it's not valid JSON, return as is
      return jsonContent;
    }
  }

  /// Gets a summary of the plain text (first 100 characters)
  static String getSummaryFromQuillJson(String jsonContent, {int maxLength = 100}) {
    final plainText = getPlainTextFromQuillJson(jsonContent);
    
    if (plainText.isEmpty) {
      return 'No content';
    }

    if (plainText.length <= maxLength) {
      return plainText;
    }

    return '${plainText.substring(0, maxLength)}...';
  }

  /// Creates a Quill document from JSON string
  static Document? documentFromJson(String jsonContent) {
    if (jsonContent.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(jsonContent);
      return Document.fromJson(decoded);
    } catch (e) {
      return null;
    }
  }
}
