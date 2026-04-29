import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Text('Timeline History', style: Get.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: controller.entriesStream,
              builder: (context, snapshot) {
                // 1. Handling Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                // 2. Handling Error
                if (snapshot.hasError) {
                  return Center(child: Text('Error has occured: ${snapshot.error}'));
                }

                // 3. Handling Empty Data
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('No activity recorded yet.', style: TextStyle(color: Colors.white54)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final Map<String, dynamic> data = docs[index].data() as Map<String, dynamic>;
                    final String docId = docs[index].id; // Ambil ID dokumen Firestore
                    final bool isLast = index == docs.length - 1;

                    // Bungkus dengan Dismissible untuk fitur Swipe to Delete
                    return Dismissible(
                      key: Key(docId),
                      direction: DismissDirection.endToStart, // Geser dari kanan ke kiri
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
                        controller.deleteEntry(docId); // Panggil fungsi delete
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
                                child: _buildLogCard(data, docId), // Lempar docId ke sini
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
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
          Text('LIFELOG', style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        ],
      ),
    );
  }

  Widget _buildTimelineNode(bool isLast) {
    return Column(
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 8)],
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
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [AppColors.primary.withValues(alpha: 0.5), AppColors.primary.withValues(alpha: 0.0)],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLogCard(Map<String, dynamic> data, String docId) {
    // 1. Ekstrak Data
    final String title = data['title']?.toString() ?? 'No Title';
    final String category = data['category']?.toString() ?? 'UNCATEGORIZED';
    final String note = data['note']?.toString() ?? '';
    final String dateStr = controller.formatTimestamp(data['createdAt'] as Timestamp?);
    
    // 2. Cek Jenis Data
    final bool isTask = data['isTask'] == true;
    final bool isDone = data['isDone'] == true;

    // 3. Tentukan Gaya Visual
    // Kalau ini Task dan BELUM selesai, tampilannya beda.
    final bool isPendingTask = isTask && !isDone; 

    // Kita pakai warna yang lebih redup untuk Task yang belum selesai
    final Color cardColor = isPendingTask ? Colors.transparent : AppColors.surface;
    final Color borderColor = isPendingTask ? AppColors.primary.withOpacity(0.3) : AppColors.primary.withOpacity(0.1);
    
    // Ikon penanda status
    final IconData statusIcon = isPendingTask ? Icons.hourglass_empty_rounded : Icons.check_circle_rounded;
    final Color statusColor = isPendingTask ? Colors.orangeAccent : AppColors.primary;

    return Container(
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
              Row(
                children: [
                  Icon(statusIcon, size: 14, color: statusColor),
                  const SizedBox(width: 8),
                  Text(category, style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ],
              ),
              Text(dateStr, style: const TextStyle(fontSize: 11, color: Colors.white38)),
            ],
          ),
          const SizedBox(height: 8),
          
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isPendingTask ? Colors.white70 : Colors.white)),
          
          if (note.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
              child: Text(note, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.white70)),
            )
          ],

          // Fitur Tambahan: Tombol "Selesaikan" untuk Pending Task
          if (isPendingTask) ...[
             const SizedBox(height: 12),
             Align(
               alignment: Alignment.centerRight,
               child: TextButton.icon(
                 onPressed: () {
                   // Panggil fungsi completeTask pakai docId
                   controller.completeTask(docId);
                 },
                 icon: const Icon(Icons.check, size: 16, color: Colors.white),
                 label: const Text('Selesaikan', style: TextStyle(color: Colors.white, fontSize: 12)),
                 style: TextButton.styleFrom(
                   backgroundColor: AppColors.primary.withOpacity(0.2),
                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                   minimumSize: Size.zero,
                   tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                 ),
               )
             )
          ]
        ],
      ),
    );
  }
}