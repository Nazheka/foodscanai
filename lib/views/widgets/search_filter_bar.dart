import 'package:flutter/material.dart';
import 'package:read_the_label/theme/app_colors.dart';

class SearchFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final Function(DateTime?) onDateFilterChanged;
  final DateTime? selectedDate;
  final bool showDateFilter;

  const SearchFilterBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onDateFilterChanged,
    this.selectedDate,
    this.showDateFilter = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search food items...',
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.primary,
              ),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          if (showDateFilter) ...[
            const SizedBox(height: 8),
            // Date Filter
            InkWell(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: AppColors.primary,
                          onPrimary: Colors.white,
                          surface: Theme.of(context).colorScheme.surface,
                          onSurface: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  onDateFilterChanged(picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedDate != null
                          ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                          : 'Filter by date',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
} 