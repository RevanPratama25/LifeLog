import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/timeline_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/category_chips.dart';
import '../../../core/widgets/entry_detail_bottom_sheet.dart';
import '../../../core/widgets/completion_bottom_sheet.dart';

class TimelineView extends GetView<TimelineController> {
  const TimelineView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),

            // Timeline list content
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: controller.entriesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  final allDocs = snapshot.data?.docs ?? [];

                  // Obx wraps only the filtered list rebuild on search/category
                  // changes, without interrupting the Firestore stream.
                  return Obx(() {
                    final String query =
                        controller.searchQuery.value.toLowerCase();
                    final String currentCategory =
                        controller.selectedCategory.value;

                    // Extract unique categories dynamically
                    final Set<String> uniqueCategories = {'ALL'};
                    for (var doc in allDocs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final cat =
                          data['category']?.toString().toUpperCase() ??
                          'UNCATEGORIZED';
                      if (cat.isNotEmpty) {
                        uniqueCategories.add(cat);
                      }
                    }
                    final dynamicCategories = uniqueCategories.toList();

                    final filteredDocs = allDocs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final title =
                          (data['title']?.toString() ?? '').toLowerCase();
                      final desc =
                          (data['description']?.toString() ?? '').toLowerCase();
                      final note =
                          (data['note']?.toString() ?? '').toLowerCase();
                      final category =
                          (data['category']?.toString() ?? '').toLowerCase();

                      final searchMatch = query.isEmpty ||
                          title.contains(query) ||
                          desc.contains(query) ||
                          note.contains(query) ||
                          category.contains(query);

                      final catMatch = currentCategory == 'ALL' ||
                          (data['category']?.toString().toUpperCase() ??
                                  'UNCATEGORIZED') ==
                              currentCategory;

                      return searchMatch && catMatch;
                    }).toList();

                    return Column(
                      children: [
                        // Shared category chips widget
                        CategoryChips(
                          categories: dynamicCategories,
                          selectedCategory: currentCategory,
                          onCategorySelected: controller.setCategory,
                        ),
                        Expanded(
                          child: filteredDocs.isEmpty
                              ? Center(
                                  child: Text(
                                    query.isEmpty
                                        ? 'No activity history yet.'
                                        : 'No results found for "$query".',
                                    style: const TextStyle(
                                      color: Colors.white54,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    24,
                                    8,
                                    24,
                                    160,
                                  ),
                                  itemCount: filteredDocs.length,
                                  itemBuilder: (context, index) {
                                    final data = filteredDocs[index].data()
                                        as Map<String, dynamic>;
                                    final String docId =
                                        filteredDocs[index].id;
                                    final bool isLast =
                                        index == filteredDocs.length - 1;

                                    // Date grouping logic
                                    final currentDate =
                                        (data['createdAt'] as Timestamp?)
                                            ?.toDate();
                                    DateTime? previousDate;

                                    if (index > 0) {
                                      final previousData =
                                          filteredDocs[index - 1].data()
                                              as Map<String, dynamic>;
                                      previousDate =
                                          (previousData['createdAt']
                                                  as Timestamp?)
                                              ?.toDate();
                                    }

                                    final bool showHeader = index == 0 ||
                                        !DateFormatters.isSameDay(
                                            currentDate, previousDate);

                                    // Timeline content with swipe-to-delete
                                    Widget timelineContent = Dismissible(
                                      key: Key(docId),
                                      direction:
                                          DismissDirection.endToStart,
                                      background: Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 24,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent.withValues(
                                            alpha: 0.8,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        alignment: Alignment.centerRight,
                                        padding: const EdgeInsets.only(
                                          right: 20,
                                        ),
                                        child: const Icon(
                                          Icons.delete_sweep,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                      onDismissed: (direction) {
                                        controller.deleteEntry(docId);
                                      },
                                      child: IntrinsicHeight(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            _buildTimelineNode(isLast),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.only(
                                                  bottom: 24.0,
                                                ),
                                                child: _buildLogCard(
                                                  data,
                                                  docId,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );

                                    // Combine date header with content
                                    if (showHeader) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildDateHeader(
                                            DateFormatters.formatDateHeader(
                                                currentDate),
                                          ),
                                          timelineContent,
                                        ],
                                      );
                                    }

                                    return timelineContent;
                                  },
                                ),
                        ),
                      ],
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Private Helper Widgets ---

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.searchController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search notes or activities...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.white54,
                  size: 20,
                ),
                suffixIcon: Obx(
                  () => controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Colors.white54,
                            size: 16,
                          ),
                          onPressed: () =>
                              controller.searchController.clear(),
                        )
                      : const SizedBox(),
                ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Obx(
            () => Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: IconButton(
                icon: Icon(
                  controller.isDescending.value
                      ? Icons.sort_rounded
                      : Icons.filter_list_alt,
                  color: AppColors.primary,
                ),
                onPressed: () => controller.toggleSort(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineNode(bool isLast) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.5),
                blurRadius: 8,
              ),
            ],
          ),
          margin: const EdgeInsets.only(top: 4),
        ),
        if (!isLast)
          Expanded(
            child: Container(
              width: 2,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.5),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLogCard(Map<String, dynamic> data, String docId) {
    final String title = data['title']?.toString() ?? 'No Title';
    final String category = data['category']?.toString() ?? 'UNCATEGORIZED';
    final String note = data['note']?.toString() ?? '';
    final timestamp = data['createdAt'] as Timestamp?;
    String timeStr = '';

    if (timestamp != null) {
      final dateObj = timestamp.toDate();
      final hour = dateObj.hour.toString().padLeft(2, '0');
      final minute = dateObj.minute.toString().padLeft(2, '0');
      timeStr = '$hour:$minute';
    }

    final bool isTask = data['isTask'] == true;
    final bool isDone = data['isDone'] == true;
    final bool isPendingTask = isTask && !isDone;

    // Use subdued style for pending tasks
    final Color cardColor =
        isPendingTask ? Colors.transparent : AppColors.surface;
    final Color borderColor = isPendingTask
        ? AppColors.primary.withValues(alpha: 0.3)
        : AppColors.primary.withValues(alpha: 0.1);

    return InkWell(
      onTap: () => showEntryDetailBottomSheet(
        data: data,
        docId: docId,
        onDelete: () => controller.deleteEntry(docId),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Time display
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Colors.white54,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeStr,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isPendingTask ? Colors.white70 : Colors.white,
              ),
            ),

            if (note.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  note,
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],

            // "Complete" button for pending tasks
            if (isPendingTask) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => showCompletionBottomSheet(
                    title: title,
                    noteController: controller.completionNoteController,
                    onConfirm: () => controller.completeTask(docId),
                  ),
                  icon: const Icon(Icons.check, size: 16, color: Colors.white),
                  label: const Text(
                    'Complete',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0, top: 12.0),
      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
              child: Divider(color: Colors.white12, thickness: 1.5)),
        ],
      ),
    );
  }
}
