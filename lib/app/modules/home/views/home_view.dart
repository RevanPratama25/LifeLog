import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:life_log_frontend/app/modules/home/controllers/home_controller.dart';
import 'package:life_log_frontend/app/routes/app_pages.dart';
import '../../../core/theme/app_colors.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildCustomAppBar(), 
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
              const SizedBox(height: 80), // Biar gak ketutup Floating Navbar
            ],
          ),
        ),
      ),
    );
  }

  //Fungsi Custom AppBar
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
        GestureDetector(
    onTap: () {
      Get.defaultDialog(
        title: 'Keluar dari LifeLog?',
        middleText: 'Sesi kamu akan berakhir. Sampai jumpa lagi, Revan!',
        backgroundColor: AppColors.surface,
        titleStyle: const TextStyle(color: Colors.white),
        middleTextStyle: const TextStyle(color: Colors.white70),
        textConfirm: 'Keluar',
        confirmTextColor: Colors.white,
        buttonColor: Colors.redAccent,
        onConfirm: () async {
          await FirebaseAuth.instance.signOut();
          Get.offAllNamed(Routes.LOGIN); // Kembali ke gerbang awal
        },
        textCancel: 'Cancel',
        cancelTextColor: Colors.white70,
      );
    },
    child: const CircleAvatar(
      radius: 14,
      backgroundImage: NetworkImage('https://i.pravatar.cc/100'), // Nanti ganti dengan foto profil user
    ),
  ),
  const SizedBox(width: 24),
],
    );
  }


  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Text(
              'Halo, ${controller.userName.value} ',
              style: Get.textTheme.displayMedium,
            )),
        const SizedBox(height: 4),
        Text(
          'Selasa, 21 April 2026', // Teks dummy
          style: Get.textTheme.bodyMedium,
        ),
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
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Bagian 1: Donut Graphic (Task Progress)
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Obx(() => CircularProgressIndicator(
                      value: controller.taskProgress,
                      strokeWidth: 10,
                      strokeCap: StrokeCap.round, // Bikin ujung garis membulat (lebih modern)
                      backgroundColor: AppColors.background,
                      color: AppColors.primary,
                    )),
              ),
              Column(
                children: [
                  Obx(() => Text(
                        controller.progressPercentage,
                        style: Get.textTheme.displayMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                  Text('Selesai', style: Get.textTheme.bodyMedium),
                ],
              )
            ],
          ),
          
          const SizedBox(height: 24),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),

          // Bagian 2: Horizontal Fire Streak
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('STREAK AKTIF', style: Get.textTheme.labelLarge?.copyWith(letterSpacing: 1.2)),
                  Obx(() => Text('${controller.streakDays.value} Hari', 
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
                ],
              ),
              const SizedBox(height: 12),
              
              // Barisan Api Horizontal
              Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                  controller.streakDays.value,
                  (index) => Icon(
                    Icons.local_fire_department,
                    color: AppColors.primary,
                    size: 28,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: AppColors.primary.withValues(alpha: 0.8),
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ),
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
    onTap: () {
      // Kirim argumen berupa Map untuk menentukan mode
      Get.toNamed(
        Routes.ADD_ENTRY, 
        arguments: {'isTask': isPrimary},
      );
    },
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
                      color: AppColors.surface.withValues(alpha: 0.5),
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