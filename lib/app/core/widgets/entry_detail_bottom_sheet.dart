import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../../routes/app_pages.dart';

/// Shows a detail bottom sheet for an entry with Edit & Delete actions.
///
/// Extracted from near-identical implementations in [TaskView] and
/// [TimelineView]. The `home_view` versions are intentionally kept
/// separate since they have a simpler layout.
void showEntryDetailBottomSheet({
  required Map<String, dynamic> data,
  required String docId,
  required VoidCallback onDelete,
}) {
  final title = data['title']?.toString() ?? 'No Title';
  final category = data['category']?.toString() ?? 'GENERAL';
  final desc = data['description']?.toString() ?? '';
  final note = data['note']?.toString() ?? '';
  final isDone = data['isDone'] == true;

  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Category & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Icon(
                  isDone ? Icons.check_circle : Icons.hourglass_empty,
                  color: isDone ? AppColors.primary : Colors.orange,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              title,
              style: Get.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Description
            if (desc.isNotEmpty) ...[
              const Text(
                'Description:',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Notes / Insight
            if (note.isNotEmpty) ...[
              const Text(
                'Notes / Insight:',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  note,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            if (desc.isEmpty && note.isEmpty) const SizedBox(height: 8),

            const Divider(color: Colors.white12),
            const SizedBox(height: 16),

            // Action buttons (Edit & Delete)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.back();
                      // Navigate to AddEntry in edit mode
                      Get.toNamed(
                        Routes.addEntry,
                        arguments: {
                          'isEdit': true,
                          'docId': docId,
                          'data': data,
                        },
                      );
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text(
                      'Edit',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                    label: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
  );
}
