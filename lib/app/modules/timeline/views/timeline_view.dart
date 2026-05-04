import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_log_frontend/app/routes/app_pages.dart';
import '../controllers/timeline_controller.dart';
import '../../../core/theme/app_colors.dart';

class TimelineView extends GetView<TimelineController> {
  const TimelineView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildCustomAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 UI SEARCH BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: TextField(
              controller: controller.searchController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cari catatan atau aktivitas...',
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
                          onPressed: () => controller.searchController.clear(),
                        )
                      : const SizedBox(),
                ),
                filled: true,
                fillColor: AppColors.surface, // Atau Colors.white10
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),

          // 🔥 KONTEN TIMELINE LIST
          Expanded(
            // Obx DIHAPUS dari sini, StreamBuilder dibiarkan murni nempel ke Firebase
            child: StreamBuilder<QuerySnapshot>(
              stream: controller.entriesStream, 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                final allDocs = snapshot.data?.docs ?? [];

                // 🔥 OBX DIPINDAH KE SINI!
                // Sekarang Obx cuma nge-rebuild list-nya doang tiap kali lu ngetik, 
                // tanpa mutus stream/koneksi ke database. Instant & No Loading!
                return Obx(() {
                  final String query = controller.searchQuery.value.toLowerCase();
                  
                  final filteredDocs = allDocs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final title = (data['title']?.toString() ?? '').toLowerCase();
                    final desc = (data['description']?.toString() ?? '').toLowerCase();
                    final note = (data['note']?.toString() ?? '').toLowerCase();
                    final category = (data['category']?.toString() ?? '').toLowerCase(); // 🔥 Ditambahin biar bisa nyari kategori

                    return query.isEmpty || 
                           title.contains(query) || 
                           desc.contains(query) || 
                           note.contains(query) ||
                           category.contains(query);
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return Center(
                      child: Text(
                        query.isEmpty ? 'Belum ada riwayat aktivitas.' : 'Tidak ditemukan hasil untuk "$query".',
                        style: const TextStyle(color: Colors.white54),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final data = filteredDocs[index].data() as Map<String, dynamic>;
                      final String docId = filteredDocs[index].id;
                      final bool isLast = index == filteredDocs.length - 1;

                      // 🔥 LOGIKA DATE GROUPING (Tetap Aman)
                      final currentDate = (data['createdAt'] as Timestamp?)?.toDate();
                      DateTime? previousDate;
                      
                      if (index > 0) {
                        final previousData = filteredDocs[index - 1].data() as Map<String, dynamic>;
                        previousDate = (previousData['createdAt'] as Timestamp?)?.toDate();
                      }

                      final bool showHeader = index == 0 || !_isSameDay(currentDate, previousDate);

                      // 🔥 KONTEN TIMELINE BESERTA DISMISSIBLE
                      Widget timelineContent = Dismissible(
                        key: Key(docId),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete_sweep, color: Colors.white, size: 30),
                        ),
                        onDismissed: (direction) {
                          controller.deleteEntry(docId);
                        },
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildTimelineNode(isLast),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 24.0),
                                  child: _buildLogCard(data, docId), 
                                ),
                              ),
                            ],
                          ),
                        ),
                      );

                      // 🔥 GABUNGKAN HEADER & KONTEN
                      if (showHeader) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDateHeader(_getDateHeader(currentDate)),
                            timelineContent,
                          ],
                        );
                      }

                      return timelineContent;
                    },
                  );
                }); // Tutup Obx
              },
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // --- Sub Widgets ---

  AppBar _buildCustomAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          const Icon(Icons.bubble_chart, color: AppColors.primary, size: 28),
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
    //  Ekstrak Data
    final String title = data['title']?.toString() ?? 'No Title';
    final String category = data['category']?.toString() ?? 'UNCATEGORIZED';
    final String note = data['note']?.toString() ?? '';
    final String dateStr = controller.formatTimestamp(
      data['createdAt'] as Timestamp?,
    );

    final timestamp = data['createdAt'] as Timestamp?;
    String timeStr = '';

    if (timestamp != null) {
      final dateObj = timestamp.toDate();
      // padLeft(2, '0') fungsinya biar angka di bawah 10 dikasih '0' di depannya
      // Contoh: Jam 9 lebih 5 menit -> jadinya "09:05", bukan "9:5"
      final hour = dateObj.hour.toString().padLeft(2, '0');
      final minute = dateObj.minute.toString().padLeft(2, '0');
      timeStr = '$hour:$minute';
    }

    //  Cek Jenis Data
    final bool isTask = data['isTask'] == true;
    final bool isDone = data['isDone'] == true;

    //  Tentukan Gaya Visual
    // Kalau ini Task dan BELUM selesai, tampilannya beda.
    final bool isPendingTask = isTask && !isDone;

    // Kita pakai warna yang lebih redup untuk Task yang belum selesai
    final Color cardColor = isPendingTask
        ? Colors.transparent
        : AppColors.surface;
    final Color borderColor = isPendingTask
        ? AppColors.primary.withOpacity(0.3)
        : AppColors.primary.withOpacity(0.1);

    // Ikon penanda status
    final IconData statusIcon = isPendingTask
        ? Icons.hourglass_empty_rounded
        : Icons.check_circle_rounded;
    final Color statusColor = isPendingTask
        ? Colors.orangeAccent
        : AppColors.primary;

    return InkWell(
      onTap: () =>
          _showDetailBottomSheet(data, docId), //Panggil bottom sheet di sini
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          // Tambahkan efek dashed border nanti kalau perlu, tapi untuk sekarang border solid yang tipis udah cukup membedakan.
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

                // Ganti Text tanggal lu yang lama dengan ini:
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Colors.white54,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeStr, // <- Manggil variabel jam yang udah kita format
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

            // Additional Features: Tombol "Complete" untuk Pending Task
            if (isPendingTask) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  // Call Bottom Sheet
                  onPressed: () => _showCompletionPrompt(docId, title),
                  icon: const Icon(Icons.check, size: 16, color: Colors.white),
                  label: const Text(
                    'Complete',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.2),
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

  void _showCompletionPrompt(String docId, String title) {
    controller.completionNoteController.clear();

    Get.bottomSheet(
      Builder(
        builder: (context) {
          return Container(
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

                  Text(
                    'Complete the Task',
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

                  TextField(
                    controller: controller.completionNoteController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText:
                          'Any insights or lessons from this activity? (Optional)',
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

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => controller.completeTask(
                        docId,
                      ), // Call completeTask from TimelineController
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
      isScrollControlled: true,
    );
  }

  void _showDetailBottomSheet(Map<String, dynamic> data, String docId) {
    final title = data['title']?.toString() ?? 'No Title';
    final category = data['category']?.toString() ?? 'UNCATEGORIZED';
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

              Text(
                title,
                style: Get.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Tampilkan Deskripsi jika ada
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
                const SizedBox(height: 16),
              ],

              // Tampilkan Insight/Note jika ada (khusus untuk Timeline)
              if (note.isNotEmpty) ...[
                const Text(
                  'Catatan / Insight:',
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

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                        // Lempar ke form Edit yang udah kita bikin pintar
                        Get.toNamed(
                          Routes.ADD_ENTRY,
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
                      onPressed: () => controller.deleteEntry(docId),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Hapus',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.withOpacity(0.8),
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

  // 1. Cek apakah dua tanggal berada di hari yang sama
  bool _isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // 2. Format tanggal jadi teks (Hari Ini, Kemarin, atau 24 Apr 2026)
  String _getDateHeader(DateTime? date) {
    if (date == null) return 'Tidak Diketahui';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) return 'HARI INI';
    if (targetDate == yesterday) return 'KEMARIN';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // 3. UI Header Tanggal yang modern (mirip pembatas bab)
  Widget _buildDateHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0, top: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
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
          const Expanded(child: Divider(color: Colors.white12, thickness: 1.5)),
        ],
      ),
    );
  }
}
