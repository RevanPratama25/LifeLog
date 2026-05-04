import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:life_log_frontend/app/modules/tasks/controllers/tasks_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_pages.dart';

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
              const Icon(
                Icons.bubble_chart,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                'LIFELOG',
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
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
            Obx(
              () => IconButton(
                icon: Icon(
                  controller.isDescending.value
                      ? Icons.sort_rounded
                      : Icons.filter_list_alt,
                  color: AppColors.primary,
                ),
                onPressed: () => controller.toggleSort(),
              ),
            ),
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
      final stream = isTaskList
          ? controller.activeTasksStream
          : controller.logsStream;
      final currentCategory = controller.selectedCategory.value;

      return StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final allDocs = snapshot.data?.docs ?? [];

          // 🔥 MAGIC HAPPENS HERE: Ekstrak kategori secara dinamis
          final Set<String> uniqueCategories = {
            'ALL',
          }; // Selalu pastikan 'ALL' ada di urutan pertama
          for (var doc in allDocs) {
            final data = doc.data() as Map<String, dynamic>;
            final cat =
                data['category']?.toString().toUpperCase() ?? 'UNCATEGORIZED';
            if (cat.isNotEmpty) {
              uniqueCategories.add(cat);
            }
          }
          final dynamicCategories = uniqueCategories.toList();

          // Saring data berdasarkan kategori yang lagi dipilih
          final filteredDocs = currentCategory == 'ALL'
              ? allDocs
              : allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return (data['category']?.toString().toUpperCase() ?? '') ==
                      currentCategory;
                }).toList();

          return Column(
            children: [
              // 🔥 Lempar list kategori dinamis ke fungsi pembangun chips
              _buildCategoryChips(dynamicCategories),

              Expanded(
                child: filteredDocs.isEmpty
                    ? Center(
                        child: Text(
                          currentCategory == 'ALL'
                              ? (isTaskList
                                    ? 'Tidak ada rencana aktif.'
                                    : 'Belum ada log selesai.')
                              : 'Tidak ada data untuk kategori $currentCategory.',
                          style: const TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {
                          final data =
                              filteredDocs[index].data()
                                  as Map<String, dynamic>;
                          final docId = filteredDocs[index].id;
                          return _buildCustomCard(data, docId, isTaskList);
                        },
                      ),
              ),
            ],
          );
        },
      );
    });
  }

  // 🔥 Tambahkan parameter List<String>
  Widget _buildCategoryChips(List<String> categories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Obx(
        () => Row(
          // 🔥 Gunakan parameter 'categories' di sini
          children: categories.map((cat) {
            final isActive = controller.selectedCategory.value == cat;
            return GestureDetector(
              onTap: () => controller.setCategory(cat),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? AppColors.primary : Colors.white12,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    color: isActive ? Colors.black : Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCustomCard(
    Map<String, dynamic> data,
    String docId,
    bool isTaskList,
  ) {
    return InkWell(
      onTap: () => _showDetailBottomSheet(data, docId),
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
                    onPressed: () => _showCompletionPrompt(
                      docId,
                      data['title']?.toString() ?? 'Task',
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

  // 🔥 Fungsi untuk memunculkan input Insight saat complete task
  void _showCompletionPrompt(String docId, String title) {
    // Pastikan text field kosong setiap kali dibuka
    controller.completionNoteController.clear();

    Get.bottomSheet(
      // 🔥 PENTING: Gunakan Builder agar kita bisa ambil context untuk deteksi keyboard
      Builder(
        builder: (context) {
          return Container(
            // Padding bawah kita dinamis ngikutin tinggi keyboard biar gak ketutupan!
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              left: 24,
              right: 24,
              top: 24,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              // 🔥 BUNGKUS COLUMN PAKAI INI
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

                  Text(
                    'Completing Task',
                    style: Get.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Input Insight
                  TextField(
                    controller: controller.completionNoteController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText:
                          'Any insights or learnings from this activity? (Optional)',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.black12,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tombol Submit
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => controller.markAsDone(docId),
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text(
                        'Mark as Done',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled:
          true, // Wajib true agar bottom sheet bisa naik saat keyboard muncul
    );
  }

  // 🔥 Fungsi untuk memunculkan Bottom Sheet Detail
  void _showDetailBottomSheet(Map<String, dynamic> data, String docId) {
    final title = data['title']?.toString() ?? 'No Title';
    final category = data['category']?.toString() ?? 'GENERAL';
    final desc = data['description']?.toString() ?? '';
    final isDone = data['isDone'] == true;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface, // Sesuaikan dengan warna surface lu
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Biar tingginya nyesuaiin konten
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar (garis kecil di atas)
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

            // Kategori & Status
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

            // Judul
            Text(
              title,
              style: Get.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Deskripsi (Bisa panjang)
            if (desc.isNotEmpty) ...[
              const Text(
                'Deskripsi:',
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
              const SizedBox(height: 24),
            ],

            const Divider(color: Colors.white12),
            const SizedBox(height: 16),

            // Tombol Action (Edit & Delete)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.back(); // Tutup bottom sheet dulu
                      // 🔥 Lempar data ke halaman AddEntry
                      Get.toNamed(
                        Routes.ADD_ENTRY,
                        arguments: {
                          'isEdit': true,
                          'docId': docId,
                          'data': data,
                        },
                      );
                      // (Catatan: Pastikan nama route lu bener, misal Routes.ADD_ENTRY kalau lu pake konstanta)
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text(
                      'Edit',
                      style: TextStyle(color: Colors.white),
                    ),
                    // ... (style tetep sama)
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
                    onPressed: () {
                      // 🔥 Panggil fungsi hapus
                      controller.deleteTask(docId);
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                    label: const Text(
                      'Hapus',
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
            const SizedBox(
              height: 16,
            ), // Extra padding bawah biar aman di iOS/Android
          ],
        ),
      ),
      isScrollControlled:
          true, // Biar bottom sheet bisa agak tinggi kalau teksnya panjang
    );
  }
}
