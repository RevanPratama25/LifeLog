import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/timeline_controller.dart';
import '../../../core/theme/app_colors.dart';

class TimelineView extends GetView<TimelineController> {
  const TimelineView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildCustomAppBar(), // 🔥 1. Pakai Custom AppBar
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 2. Pindahkan Judul ke sini
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Text('Riwayat Aktivitas', style: Get.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          
          Expanded(
            child: Obx(() {
              if (controller.historyLogs.isEmpty) {
                return const Center(child: Text('Belum ada aktivitas tercatat.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                itemCount: controller.historyLogs.length,
                itemBuilder: (context, index) {
                  final log = controller.historyLogs[index];
                  final isLast = index == controller.historyLogs.length - 1;

                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTimelineNode(isLast),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: _buildLogCard(log),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 80), // Biar gak ketutup navbar bawah
        ],
      ),
    );
  }

  // 🔥 3. Fungsi Custom AppBar
  AppBar _buildCustomAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          Icon(Icons.bubble_chart, color: AppColors.primary, size: 28),
          const SizedBox(width: 8),
          Text('LIFELOG', style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.notifications_none, color: Colors.white70), onPressed: () {}),
        const CircleAvatar(radius: 14, backgroundImage: NetworkImage('https://i.pravatar.cc/100')),
        const SizedBox(width: 24),
      ],
    );
  }
  // Komponen pembentuk garis dan titik bercahaya
  Widget _buildTimelineNode(bool isLast) {
    return Column(
      children: [
        // Glowing Dot
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.6),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          margin: const EdgeInsets.only(top: 4), // Sejajarkan dengan judul card
        ),
        // Garis vertikal (hilangkan jika ini item terakhir)
        if (!isLast)
          Expanded(
            child: Container(
              width: 2,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                // Efek gradasi pada garis agar lebih estetik
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withOpacity(0.5),
                    AppColors.primary.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Komponen pembentuk Card Log
  Widget _buildLogCard(Map<String, String> log) {
    final hasNote = log['note'] != null && log['note']!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card: Kategori & Tanggal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                log['category']!.toUpperCase(),
                style: Get.textTheme.labelLarge?.copyWith(
                  fontSize: 10,
                  letterSpacing: 1.2,
                  color: AppColors.primary,
                ),
              ),
              Text(
                log['date']!,
                style: Get.textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Judul Aktivitas
          Text(log['title']!, style: Get.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
          
          // Insight/Note (Hanya muncul jika ada)
          if (hasNote) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: const Border(left: BorderSide(color: AppColors.primary, width: 3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.format_quote_rounded, color: AppColors.primary, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      log['note']!,
                      style: Get.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ]
        ],
      ),
    );
  }
}