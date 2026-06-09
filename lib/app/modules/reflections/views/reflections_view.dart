import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../routes/app_pages.dart';
import '../controllers/reflections_controller.dart';

class ReflectionView extends GetView<ReflectionController> {
  const ReflectionView({super.key});

  /// Shows the full note in a bottom sheet with Edit/Delete actions.
  void _showNoteDetail(Map<String, dynamic> data, String docId) {
    final note = data['note']?.toString() ?? '';
    final title = data['title']?.toString() ?? 'Activity';
    final category = data['category']?.toString() ?? 'UNCATEGORIZED';
    final timestamp = data['createdAt'] as Timestamp?;
    final dateStr = DateFormatters.formatShortDate(timestamp?.toDate());

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    category,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    dateStr,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Georgia', // Serif font for premium feel
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white12),
              const SizedBox(height: 16),

              Text(
                note,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  height: 1.8,
                  letterSpacing: 0.5,
                  fontFamily: 'Georgia', // Serif font for readability
                ),
              ),

              const SizedBox(height: 32),
              const Divider(color: Colors.white12),
              const SizedBox(height: 16),

              // Edit & Delete action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Get.back();
                        await Future.delayed(const Duration(milliseconds: 150));

                        Get.toNamed(Routes.addEntry, arguments: {
                          'isEdit': true,
                          'docId': docId,
                          'data': data,
                        });
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
                      // Ensure controller.deleteEntry exists in ReflectionController
                      onPressed: () => controller.deleteEntry(docId),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
        stream: controller.entriesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final allDocs = snapshot.data?.docs ?? [];

          // Filter: only keep entries that have non-empty 'note' field
          final docsWithNotes = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final note = data['note']?.toString().trim() ?? '';
            return note.isNotEmpty;
          }).toList();

          if (docsWithNotes.isEmpty) {
            return _buildEmptyState();
          }

          // Group by 'category'
          Map<String, List<QueryDocumentSnapshot>> groupedNotes = {};

          for (var doc in docsWithNotes) {
            final data = doc.data() as Map<String, dynamic>;
            final category =
                data['category']?.toString().toUpperCase() ?? 'UNCATEGORIZED';

            if (!groupedNotes.containsKey(category)) {
              groupedNotes[category] = [];
            }
            groupedNotes[category]!.add(doc);
          }

          // Render the UI based on selected folder state
          return Obx(() {
            final selectedFolder = controller.selectedFolder.value;

            if (selectedFolder == null) {
              // Show Folder Grid
              return GridView.builder(
                padding: const EdgeInsets.all(24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                itemCount: groupedNotes.length,
                itemBuilder: (context, index) {
                  final category = groupedNotes.keys.elementAt(index);
                  final count = groupedNotes[category]!.length;
                  
                  return InkWell(
                    onTap: () => controller.selectedFolder.value = category,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.folder, size: 48, color: AppColors.primary),
                          const SizedBox(height: 12),
                          Text(
                            category,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$count Notes',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              // Show Notes List for the selected folder
              final notesList = groupedNotes[selectedFolder] ?? [];
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => controller.selectedFolder.value = null,
                        ),
                        Text(
                          selectedFolder,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 160),
                      itemCount: notesList.length,
                      itemBuilder: (context, index) {
                        final doc = notesList[index];
                        final data = doc.data() as Map<String, dynamic>;
                        return _buildQuoteCard(data, doc.id);
                      },
                    ),
                  ),
                ],
              );
            }
          });
        },
      ),
      ),
    );
  }


  // Quote card widget (max 3 lines preview)
  Widget _buildQuoteCard(Map<String, dynamic> data, String docId) {
    final note = data['note']?.toString() ?? '';
    final title = data['title']?.toString() ?? 'Activity';
    final timestamp = data['createdAt'] as Timestamp?;
    final dateStr = DateFormatters.formatShortDate(timestamp?.toDate());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _showNoteDetail(data, docId),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: AppColors.primary, width: 4)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text preview (max 3 lines with ellipsis)
                Text(
                  '"$note"',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 12),

                Row(
                  children: [
                    const Icon(
                      Icons.bookmark_outline,
                      color: Colors.white54,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.white38,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Empty state when no insights exist yet.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 64,
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Insights Yet.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Complete plans and record\nyour learnings here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
