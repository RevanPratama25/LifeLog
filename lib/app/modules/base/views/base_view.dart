import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_log_frontend/app/routes/app_pages.dart';
import '../controllers/base_controller.dart';
import '../../../core/theme/app_colors.dart';

class BaseView extends GetView<BaseController> {
  const BaseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Obx(() => controller.screens[controller.currentIndex.value]),
      
      // TAMBAHKAN FAB DI SINI
      floatingActionButton: Obx(() => _buildContextualFAB()),
      
      bottomNavigationBar: _buildFloatingNavbar(),
    );
  }

  Widget _buildContextualFAB() {
    int index = controller.currentIndex.value;

    return FloatingActionButton(
      backgroundColor: AppColors.primary,
      elevation: 10,
      shape: const CircleBorder(),
      onPressed: () {
        if (index == 1) {
          // Tab Tasks: Otomatis mode Task
          Get.toNamed(Routes.ADD_ENTRY, arguments: {'isTask': true});
        } else if (index == 3) {
          // Tab Reflections: Otomatis mode Log
          Get.toNamed(Routes.ADD_ENTRY, arguments: {'isTask': false});
        } else {
          // Tab Dashboard/Timeline: Tampilkan Bottom Sheet Pilihan
          _showEntryOptions();
        }
      },
      child: const Icon(Icons.add, color: Colors.black, size: 30),
    );
  }

  void _showEntryOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add_task, color: AppColors.primary),
              title: const Text('Buat Rencana Baru (Task)'),
              onTap: () {
                Get.back();
                Get.toNamed(Routes.ADD_ENTRY, arguments: {'isTask': true});
              },
            ),
            const Divider(color: Colors.white10),
            ListTile(
              leading: const Icon(Icons.lightbulb_outline, color: AppColors.primary),
              title: const Text('Catat Aktivitas Baru (Log)'),
              onTap: () {
                Get.back();
                Get.toNamed(Routes.ADD_ENTRY, arguments: {'isTask': false});
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingNavbar() {
    return Obx(() => Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changePage,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.task_alt_outlined),
              activeIcon: Icon(Icons.task_alt),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.timeline),
              activeIcon: Icon(Icons.timeline),
              label: 'Timeline',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb_outline),
              activeIcon: Icon(Icons.lightbulb),
              label: 'Insights',
            ),
          ],
        ),
      ),
    ));
  }
}