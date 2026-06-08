import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/base_controller.dart';
import 'dart:ui';
import '../../../core/theme/app_colors.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/widgets/profile_avatar.dart';

class BaseView extends GetView<BaseController> {
  BaseView({super.key});

  final AuthController _authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: _buildCustomAppBar(),
      body: Obx(() => controller.screens[controller.currentIndex.value]),
      
      // Add FAB
      floatingActionButton: Obx(() => _buildContextualFAB()),
      
      bottomNavigationBar: _buildFloatingNavbar(),
    );
  }

  AppBar _buildCustomAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface.withValues(alpha: 0.85),
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      title: Row(
        children: [
          const Icon(Icons.bubble_chart, color: AppColors.primary, size: 28),
          const SizedBox(width: 8),
          Text(
            'LIFELOG',
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
      actions: [
        Obx(() {
          final unread = controller.unreadCount.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_active, color: AppColors.primary),
                onPressed: () => _showNotificationPanel(),
                tooltip: 'Pending Reminders',
              ),
              if (unread > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unread > 9 ? '9+' : unread.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
        _buildProfileMenu(),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildProfileMenu() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      onSelected: (value) {
        if (value == 'edit_profile') {
          Get.toNamed(Routes.editProfile);
        } else if (value == 'logout') {
          _authController.logout();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'edit_profile',
          child: Row(
            children: const [
              Icon(Icons.person_outline, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('Edit Profile', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: const [
              Icon(Icons.logout, color: Colors.redAccent, size: 20),
              SizedBox(width: 12),
              Text('Logout', style: TextStyle(color: Colors.redAccent)),
            ],
          ),
        ),
      ],
      child: const ProfileAvatar(radius: 18),
    );
  }

  void _showNotificationPanel() {
    controller.markAllAsRead();
    
    Get.dialog(
      Align(
        alignment: Alignment.topRight,
        child: Container(
          width: 320,
          margin: const EdgeInsets.only(top: kToolbarHeight + 16, right: 16),
          constraints: BoxConstraints(maxHeight: Get.height * 0.6),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Notifications',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                        onPressed: () => Get.back(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Colors.white12),
                Flexible(
                  child: Obx(() {
                    final notifications = controller.notifications;
                    if (notifications.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.notifications_active_outlined, color: AppColors.primary.withValues(alpha: 0.8), size: 48),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'No Notifications Yet',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "You're all caught up.\nUpcoming reminders will appear here.",
                              style: TextStyle(
                                color: Colors.white54,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notif = notifications[index];
                        final time = notif['time'] as DateTime;
                        final isRead = notif['isRead'] as bool;
                        
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: const Border(bottom: BorderSide(color: Colors.white12)),
                            color: isRead ? Colors.transparent : AppColors.primary.withValues(alpha: 0.05),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.alarm, color: AppColors.primary, size: 16),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notif['title'] ?? '',
                                      style: TextStyle(
                                        color: isRead ? Colors.white70 : Colors.white,
                                        fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContextualFAB() {
    int index = controller.currentIndex.value;

    return FloatingActionButton(
      backgroundColor: AppColors.primary,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Radius 16
      ),
      onPressed: () {
        if (index == 1) {
          // Tab Tasks: Auto-select Task mode
          Get.toNamed(Routes.addEntry, arguments: {'isTask': true});
        } else if (index == 3) {
          // Tab Reflections: Auto-select Log mode
          Get.toNamed(Routes.addEntry, arguments: {'isTask': false});
        } else {
          // Dashboard/Timeline: Show selection bottom sheet
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
              title: const Text('Create New Plan (Task)'),
              onTap: () {
                Get.back();
                Get.toNamed(Routes.addEntry, arguments: {'isTask': true});
              },
            ),
            const Divider(color: Colors.white10),
            ListTile(
              leading: const Icon(Icons.lightbulb_outline, color: AppColors.primary),
              title: const Text('Record New Activity (Log)'),
              onTap: () {
                Get.back();
                Get.toNamed(Routes.addEntry, arguments: {'isTask': false});
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
              label: 'List',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb_outline),
              activeIcon: Icon(Icons.lightbulb),
              label: 'Insight',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.timeline),
              activeIcon: Icon(Icons.timeline),
              label: 'Timeline',
            ),
          ],
        ),
      ),
    ));
  }
}