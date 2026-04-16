import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../core/theme/app_colors.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildStreakCard(),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 32),
              _buildTodayFocus(),
              const SizedBox(height: 32),
              _buildRecentReflections(),
            ],
          ),
        ),
      ),
    );
  }

  // 1. HEADER
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Text(
                  'Halo, ${controller.userName.value} 👋',
                  style: Get.textTheme.displayMedium,
                )),
            const SizedBox(height: 4),
            Text(
              'Kamis, 16 April 2026', // Nanti pakai library intl buat tanggal dinamis
              style: Get.textTheme.bodyMedium,
            ),
          ],
        ),
        Icon(Icons.notifications_outlined, color: AppColors.primary, size: 28),
      ],
    );
  }

  // 2. HERO WIDGET (STREAK) DENGAN GLOW EFFECT
  Widget _buildStreakCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
        boxShadow: [
          // Ini efek GLOW-nya 🔥
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: 0.7, // Dummy progress
                  strokeWidth: 8,
                  backgroundColor: AppColors.background,
                  color: AppColors.primary,
                ),
              ),
              Column(
                children: [
                  const Icon(Icons.local_fire_department, color: AppColors.primary, size: 28),
                  Obx(() => Text(
                        '${controller.streakDays.value}',
                        style: Get.textTheme.displayLarge?.copyWith(color: AppColors.primary),
                      )),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          Text('Hari Streak Terjaga!', style: Get.textTheme.titleLarge),
          const SizedBox(height: 8),
          Obx(() => Text(
                'Total Log: ${controller.totalLogsToday.value} | Selesai Hari Ini: ${controller.finishedToday.value}',
                style: Get.textTheme.bodyMedium,
              )),
        ],
      ),
    );
  }

  // 3. QUICK ACTIONS
  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _actionButton('Rencana', Icons.add_task, isPrimary: true),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _actionButton('Aktivitas', Icons.add_chart, isPrimary: false),
        ),
      ],
    );
  }

  Widget _actionButton(String title, IconData icon, {required bool isPrimary}) {
    return InkWell(
      onTap: () {}, // Nanti diisi route Get.toNamed()
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPrimary ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isPrimary ? AppColors.primary : AppColors.textPrimary, size: 20),
            const SizedBox(width: 8),
            Text(title, style: Get.textTheme.labelLarge?.copyWith(
              color: isPrimary ? AppColors.primary : AppColors.textPrimary,
            )),
          ],
        ),
      ),
    );
  }

  // 4. TODAY'S FOCUS
  Widget _buildTodayFocus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('FOKUS HARI INI', style: Get.textTheme.labelLarge?.copyWith(color: AppColors.textSecondary, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        Obx(() => Column(
              children: controller.todayTasks.map((task) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.circle_outlined, color: AppColors.textSecondary),
                      title: Text(task['title'] as String, style: Get.textTheme.bodyLarge),
                    ),
                  )).toList(),
            )),
      ],
    );
  }

  // 5. RECENT REFLECTIONS
  Widget _buildRecentReflections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('REFLEKSI TERBARU', style: Get.textTheme.labelLarge?.copyWith(color: AppColors.textSecondary, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        Obx(() => Column(
              children: controller.recentLogs.map((log) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.surface),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(log['title'] as String, style: Get.textTheme.bodyLarge),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '"${log['note']}"',
                                style: Get.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )).toList(),
            )),
      ],
    );
  }
}