import 'package:flutter/material.dart';

/// Configuration for filter dialog options
class FilterDialogConfig {
  final String selectedCategory;
  final String sortBy;
  final bool showPinnedOnly;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final List<String> categoryOptions;
  final bool showDateFilter;

  const FilterDialogConfig({
    required this.selectedCategory,
    required this.sortBy,
    required this.showPinnedOnly,
    this.dateFrom,
    this.dateTo,
    required this.categoryOptions,
    this.showDateFilter = false,
  });
}

/// Result returned from the filter dialog
class FilterDialogResult {
  final String category;
  final String sortBy;
  final bool showPinnedOnly;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final bool wasReset;

  const FilterDialogResult({
    required this.category,
    required this.sortBy,
    required this.showPinnedOnly,
    this.dateFrom,
    this.dateTo,
    this.wasReset = false,
  });
}

/// A reusable filter dialog widget for filtering and sorting notes
class FilterDialogWidget extends StatefulWidget {
  const FilterDialogWidget({
    super.key,
    required this.config,
  });

  final FilterDialogConfig config;

  @override
  State<FilterDialogWidget> createState() => _FilterDialogWidgetState();
}

class _FilterDialogWidgetState extends State<FilterDialogWidget> {
  late String _tempCategory;
  late String _tempSortBy;
  late bool _tempShowPinnedOnly;
  late DateTime? _tempDateFrom;
  late DateTime? _tempDateTo;

  @override
  void initState() {
    super.initState();
    _tempCategory = widget.config.selectedCategory;
    _tempSortBy = widget.config.sortBy;
    _tempShowPinnedOnly = widget.config.showPinnedOnly;
    _tempDateFrom = widget.config.dateFrom;
    _tempDateTo = widget.config.dateTo;
  }

  void _reset() {
    Navigator.of(context).pop(
      const FilterDialogResult(
        category: 'All',
        sortBy: 'Recent',
        showPinnedOnly: false,
        dateFrom: null,
        dateTo: null,
        wasReset: true,
      ),
    );
  }

  void _apply() {
    Navigator.of(context).pop(
      FilterDialogResult(
        category: _tempCategory,
        sortBy: _tempSortBy,
        showPinnedOnly: _tempShowPinnedOnly,
        dateFrom: _tempDateFrom,
        dateTo: _tempDateTo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Filter & Sort'),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Filter
            Text(
              'Category',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Wrap(
              spacing: 8,
              children: widget.config.categoryOptions.map((category) {
                final isSelected = _tempCategory == category;
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _tempCategory = selected ? category : 'All';
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Sort Options
            Text(
              'Sort By',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _tempSortBy,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 'Recent', child: Text('Most Recent')),
                DropdownMenuItem(value: 'Oldest', child: Text('Oldest First')),
                DropdownMenuItem(value: 'Title A-Z', child: Text('Title (A-Z)')),
                DropdownMenuItem(value: 'Title Z-A', child: Text('Title (Z-A)')),
              ],
              onChanged: (value) {
                setState(() {
                  _tempSortBy = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Pinned Only Filter
            CheckboxListTile(
              title: const Text('Show Pinned Only'),
              contentPadding: EdgeInsets.zero,
              value: _tempShowPinnedOnly,
              onChanged: (value) {
                setState(() {
                  _tempShowPinnedOnly = value ?? false;
                });
              },
            ),

            // Date Range Filter (optional)
            if (widget.config.showDateFilter) ...[
              const SizedBox(height: 8),
              Text(
                'Date Range',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(
                        _tempDateFrom == null
                            ? 'From'
                            : '${_tempDateFrom!.month}/${_tempDateFrom!.day}/${_tempDateFrom!.year}',
                      ),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _tempDateFrom ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() {
                            _tempDateFrom = date;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(
                        _tempDateTo == null
                            ? 'To'
                            : '${_tempDateTo!.month}/${_tempDateTo!.day}/${_tempDateTo!.year}',
                      ),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _tempDateTo ?? DateTime.now(),
                          firstDate: _tempDateFrom ?? DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() {
                            _tempDateTo = date;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              if (_tempDateFrom != null || _tempDateTo != null)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _tempDateFrom = null;
                      _tempDateTo = null;
                    });
                  },
                  child: const Text('Clear Dates'),
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _reset,
          child: const Text('Reset'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _apply,
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
