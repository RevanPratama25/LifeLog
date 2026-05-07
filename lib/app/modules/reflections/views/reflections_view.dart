import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/reflections_controller.dart';

class ReflectionView extends GetView<ReflectionController> {
  const ReflectionView({super.key});

  // Helper untuk format tanggal di bawah quote
  String _formatDate(DateTime? date) {
    if (date == null) return '';
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

  // Fungsi untuk memunculkan Full Note
  // 🔥 Fungsi Bottom Sheet Detail + Tombol Edit/Delete
  void _showNoteDetail(Map<String, dynamic> data, String docId) {
    final note = data['note']?.toString() ?? '';
    final title = data['title']?.toString() ?? 'Aktivitas';
    final category = data['category']?.toString() ?? 'UNCATEGORIZED';
    final timestamp = data['createdAt'] as Timestamp?;
    final dateStr = _formatDate(timestamp?.toDate());

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF121212), // Warna background bottom sheet
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
                      color: Colors.teal,
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white12),
              const SizedBox(height: 16),

              Text(
                note,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.6,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 32),
              const Divider(color: Colors.white12),
              const SizedBox(height: 16),

              // 🔥 TOMBOL EDIT & DELETE DI SINI
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Get.back();
                        await Future.delayed(const Duration(milliseconds: 150));
                        
                        // 🔥 Ganti '/add-entry' dengan nama konstanta Route lu!
                        // Biasanya pakai Routes.ADD_ENTRY
                        Get.toNamed(Routes.ADD_ENTRY, arguments: { 
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
                      // Pastikan controller.deleteEntry udah ada di ReflectionController lu
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reflections',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
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

          // 🔥 1. FILTERING: Cuma ambil yang punya field 'note' dan isinya nggak kosong
          final docsWithNotes = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final note = data['note']?.toString().trim() ?? '';
            return note.isNotEmpty;
          }).toList();

          if (docsWithNotes.isEmpty) {
            return _buildEmptyState();
          }

          // 🔥 2. GROUPING: Kelompokkan berdasarkan 'category'
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

          // 🔥 3. RENDER UI
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            itemCount: groupedNotes.length,
            itemBuilder: (context, index) {
              final category = groupedNotes.keys.elementAt(index);
              final notesList = groupedNotes[category]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryHeader(category, notesList.length),
                  ...notesList.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final docId = doc.id; // 🔥 Ambil docId
                    return _buildQuoteCard(data, docId); // 🔥 Lempar data dan docId
                  }).toList(),
                  const SizedBox(height: 32), // Jarak antar kategori
                ],
              );
            },
          );
        },
      ),
    );
  }

  // UI: Header Kategori
  Widget _buildCategoryHeader(String category, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          const Icon(
            Icons.folder_special,
            color: Colors.teal,
            size: 20,
          ), // Ganti warna pakai AppColors.primary
          const SizedBox(width: 8),
          Text(
            category,
            style: const TextStyle(
              color: Colors.teal, // Ganti warna pakai AppColors.primary
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(
                alpha: 0.2,
              ), // AppColors.primary.withOpacity(0.2)
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.teal,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Expanded(child: Divider(color: Colors.white12, indent: 16)),
        ],
      ),
    );
  }

  // UI: Card Quote / Insight
  // 🔥 Fungsi Card Quote (Maksimal 3 Baris)
  Widget _buildQuoteCard(Map<String, dynamic> data, String docId) {
    final note = data['note']?.toString() ?? '';
    final title = data['title']?.toString() ?? 'Aktivitas';
    final timestamp = data['createdAt'] as Timestamp?;
    final dateStr = _formatDate(timestamp?.toDate());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _showNoteDetail(data, docId), // Panggil bottom sheet
          child: Container(
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: Colors.teal, width: 4)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔥 LOGIKA POTONG TEKS ADA DI SINI
                Text(
                  '"$note"',
                  maxLines: 3, // Maksimal 3 baris
                  overflow: TextOverflow
                      .ellipsis, // Otomatis jadi ... kalau kepanjangan
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

  // UI: Kalau belum ada insight sama sekali
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 64,
            color: Colors.teal.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada Insight.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Selesaikan rencana dan catat\npembelajaranmu di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
