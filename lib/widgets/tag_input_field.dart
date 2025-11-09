import 'package:flutter/material.dart';

class TagInputField extends StatefulWidget {
  const TagInputField({
    super.key,
    required this.tags,
    required this.onTagsChanged,
    this.availableTags = const [],
  });

  final List<String> tags;
  final ValueChanged<List<String>> onTagsChanged;
  final List<String> availableTags;

  @override
  State<TagInputField> createState() => _TagInputFieldState();
}

class _TagInputFieldState extends State<TagInputField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    final trimmed = tag.trim();
    if (trimmed.isEmpty || widget.tags.contains(trimmed)) {
      return;
    }

    final updatedTags = [...widget.tags, trimmed];
    widget.onTagsChanged(updatedTags);
    _controller.clear();
  }

  void _removeTag(String tag) {
    final updatedTags = widget.tags.where((t) => t != tag).toList();
    widget.onTagsChanged(updatedTags);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.tags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.tags.map((tag) {
              return Chip(
                label: Text(tag),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => _removeTag(tag),
                backgroundColor: theme.colorScheme.primaryContainer.withOpacity(
                  0.5,
                ),
                labelStyle: theme.textTheme.bodySmall,
              );
            }).toList(),
          ),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Add tags (press Enter)',
            prefixIcon: const Icon(Icons.tag, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.primary),
            ),
          ),
          onSubmitted: _addTag,
          textInputAction: TextInputAction.done,
        ),
        if (widget.availableTags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.availableTags
                .where((tag) => !widget.tags.contains(tag))
                .take(10)
                .map((tag) {
                  return ActionChip(
                    label: Text(tag),
                    onPressed: () => _addTag(tag),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.5),
                    labelStyle: theme.textTheme.bodySmall,
                  );
                })
                .toList(),
          ),
        ],
      ],
    );
  }
}
