import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:life_log_frontend/app/modules/tasks/controllers/tasks_controller.dart';
import '../../../core/theme/app_colors.dart';

class TaskView extends GetView<TaskController> {
  const TaskView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            children: [
              const Icon(Icons.bubble_chart, color: AppColors.primary, size: 28),
              const SizedBox(width: 8),
              Text('LIFELOG', style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ],
          ),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.white54,
            tabs: const [
              Tab(text: 'ACTIVE TASKS'),
              Tab(text: 'COMPLETED LOGS'),
            ],
          ),
          actions: [
            Obx(() => IconButton(
              icon: Icon(
                controller.isDescending.value ? Icons.sort_rounded : Icons.filter_list_alt,
                color: AppColors.primary,
              ),
              onPressed: () => controller.toggleSort(),
            )),
          ],
        ),
        body: TabBarView(
          children: [
            _buildDataList(isTaskList: true),
            _buildDataList(isTaskList: false),
          ],
        ),
      ),
    );
  }

  Widget _buildDataList({required bool isTaskList}) {
    return Obx(() {
      // KUNCI FIX-NYA DI SINI:
      // Kita panggil getter stream-nya di DALAM Obx. 
      // Karena getter ini butuh baca `isDescending.value`, GetX jadi paham kalau ini reaktif!
      final stream = isTaskList ? controller.activeTasksStream : controller.logsStream;
      final currentCategory = controller.selectedCategory.value; // Baca state kategori

      return Column(
        children: [
          // 🔥 1. Sisipkan Category Chips di sini
          _buildCategoryChips(),
          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Padding(padding: const EdgeInsets.all(20), child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent, fontSize: 12))));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                // 2. Ambil semua dokumen
                final allDocs = snapshot.data?.docs ?? [];
                
                // 🔥 3. CLIENT-SIDE FILTERING (Saring data sesuai kategori)
                final filteredDocs = currentCategory == 'ALL' 
                    ? allDocs 
                    : allDocs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final cat = data['category']?.toString().toUpperCase() ?? '';
                        return cat == currentCategory;
                      }).toList();

                // 4. Cek data kosong setelah difilter
                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Text(
                      currentCategory == 'ALL' 
                        ? (isTaskList ? 'Tidak ada rencana aktif.' : 'Belum ada log selesai.')
                        : 'Tidak ada data untuk kategori $currentCategory.',
                      style: const TextStyle(color: Colors.white54),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final data = filteredDocs[index].data() as Map<String, dynamic>;
                    final docId = filteredDocs[index].id;
                    return _buildCustomCard(data, docId, isTaskList);
                  },
                );
              },
            ),
          ),
        ],
      );

    });
  }

  Widget _buildCategoryChips() {
    return Obx(() => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: controller.categories.map((category) {
          final isSelected = controller.selectedCategory.value == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) controller.setCategory(category);
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : Colors.white54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ));
  }

  Widget _buildCustomCard(Map<String, dynamic> data, String docId, bool isTaskList) {
    return Container(
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
              Text(data['category']?.toString() ?? 'GENERAL', 
                  style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
              if (isTaskList)
                IconButton(
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white54),
                  onPressed: () => controller.markAsDone(docId),
                ),
            ],
          ),
          Text(data['title']?.toString() ?? 'No Title', 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text(data['description']?.toString() ?? '', 
              style: const TextStyle(fontSize: 13, color: Colors.white70)),
        ],
      ),
    );
  }
}