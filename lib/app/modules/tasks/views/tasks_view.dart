import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/tasks_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/category_chips.dart';
import '../../../core/widgets/entry_detail_bottom_sheet.dart';
import '../../../core/widgets/completion_bottom_sheet.dart';

class TaskView extends GetView<TaskController> {
  const TaskView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TabBar(
              controller: controller.tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.white54,
              tabs: const [
                Tab(text: 'ACTIVE TASKS'),
                Tab(text: 'COMPLETED LOGS'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: controller.tabController,
                children: [
                  _buildDataList(isTaskList: true),
                  _buildDataList(isTaskList: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataList({required bool isTaskList}) {
    return Column(
      children: [
        _buildSearchAndSort(),
        Expanded(
          child: Obx(() {
            final stream = isTaskList
                ? controller.activeTasksStream
                : controller.logsStream;
            final currentCategory = controller.selectedCategory.value;
            final query = controller.searchQuery.value.toLowerCase();

            return StreamBuilder<QuerySnapshot>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                final allDocs = snapshot.data?.docs ?? [];

                // Extract unique categories dynamically from the data
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

                // Filter data by the currently selected category and search query
                final filteredDocs = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final catMatch = currentCategory == 'ALL' ||
                      (data['category']?.toString().toUpperCase() ?? '') ==
                          currentCategory;

                  final title =
                      data['title']?.toString().toLowerCase() ?? '';
                  final desc =
                      data['description']?.toString().toLowerCase() ?? '';
                  final searchMatch = query.isEmpty ||
                      title.contains(query) ||
                      desc.contains(query);

                  return catMatch && searchMatch;
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
                                currentCategory == 'ALL'
                                    ? (isTaskList
                                        ? 'No active plans.'
                                        : 'No completed logs yet.')
                                    : 'No data for category $currentCategory.',
                                style:
                                    const TextStyle(color: Colors.white54),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(
                                left: 24,
                                right: 24,
                                top: 16,
                                bottom: 160,
                              ),
                              itemCount: filteredDocs.length,
                              itemBuilder: (context, index) {
                                final data = filteredDocs[index].data()
                                    as Map<String, dynamic>;
                                final docId = filteredDocs[index].id;
                                return _buildCustomCard(
                                    data, docId, isTaskList);
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSearchAndSort() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white12),
              ),
              child: TextField(
                controller: controller.searchController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search tasks...',
                  hintStyle: TextStyle(color: Colors.white38),
                  prefixIcon: Icon(Icons.search, color: Colors.white38),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

  Widget _buildCustomCard(
    Map<String, dynamic> data,
    String docId,
    bool isTaskList,
  ) {
    return InkWell(
      onTap: () => showEntryDetailBottomSheet(
        data: data,
        docId: docId,
        onDelete: () => controller.deleteTask(docId),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data['category']?.toString() ?? 'GENERAL',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isTaskList)
                  IconButton(
                    icon: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.white54,
                    ),
                    onPressed: () => showCompletionBottomSheet(
                      title: data['title']?.toString() ?? 'Task',
                      noteController: controller.completionNoteController,
                      onConfirm: () => controller.markAsDone(docId),
                    ),
                  ),
              ],
            ),
            Text(
              data['title']?.toString() ?? 'No Title',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data['description']?.toString() ?? '',
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
