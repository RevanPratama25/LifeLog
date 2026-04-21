import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import '../../../core/theme/app_colors.dart';

class TaskView extends GetView<TaskController> {
  const TaskView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject controller kalau belum ada (buat jaga-jaga kalau dipanggil langsung)
    Get.put(TaskController());

    return Scaffold(
      appBar: _buildCustomAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabToggle(),
          const SizedBox(height: 24),
          _buildTaskHeader(),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: controller.activeTasks.length,
                  itemBuilder: (context, index) {
                    return _buildTaskCard(controller.activeTasks[index]);
                  },
                )),
          ),
          const SizedBox(height: 80), // Biar gak ketutup Floating Navbar BaseView
        ],
      ),
    );
  }

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
        IconButton(icon: const Icon(Icons.search, color: Colors.white70), onPressed: () {}),
        IconButton(icon: const Icon(Icons.notifications_none, color: Colors.white70), onPressed: () {}),
      ],
    );
  }

  Widget _buildTabToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Obx(() => Row(
            children: [
              Expanded(child: _buildTabButton('Active')),
              Expanded(child: _buildTabButton('Completed')),
            ],
          )),
    );
  }

  Widget _buildTabButton(String title) {
    final isActive = controller.currentTab.value == title;
    return GestureDetector(
      onTap: () => controller.changeTab(title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? AppColors.primary.withValues(alpha: 0.5) : Colors.transparent),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isActive ? AppColors.primary : Colors.white54,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tasks', style: Get.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Obx(() => Text('You have ${controller.activeTasks.length} tasks for today', style: Get.textTheme.bodyMedium?.copyWith(color: Colors.white54))),
            ],
          ),
          Icon(Icons.filter_list, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildTaskCard(dynamic item) {
    // 1. Cast datanya biar aman
    final Map<String, dynamic> task = Map<String, dynamic>.from(item);
    
    // 2. Ekstrak data dengan Fallback Default (kalau null, otomatis jadi string kosong/default)
    final String title = task['title']?.toString() ?? 'Tanpa Judul';
    final String time = task['time']?.toString() ?? '';
    final String category = task['category']?.toString() ?? 'TASK';
    final String extras = task['extras']?.toString() ?? '';
    final bool hasNote = task['hasNote'] == true;
    final String noteText = task['noteText']?.toString() ?? '';
    final bool isHighPriority = task['isHighPriority'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2, right: 12),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white38),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.white54),
                        const SizedBox(width: 4),
                        Text(time, style: const TextStyle(fontSize: 12, color: Colors.white54)),
                        
                        if (extras.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          const Icon(Icons.attach_file, size: 14, color: Colors.white54),
                          const SizedBox(width: 4),
                          Text(extras, style: const TextStyle(fontSize: 12, color: Colors.white54)),
                        ],

                        if (isHighPriority) ...[
                          const SizedBox(width: 12),
                          const Text('! High Priority', style: TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        ]
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Text(category, style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          
          if (hasNote && noteText.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                noteText,
                style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white70, fontSize: 13),
              ),
            )
          ]
        ],
      ),
    );
  }
}