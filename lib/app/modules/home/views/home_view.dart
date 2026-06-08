import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/theme/app_colors.dart';



class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  String _formatDeadline(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDate = DateTime(date.year, date.month, date.day);
    final difference = deadlineDate.difference(today).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreeting(),
              const SizedBox(height: 32),
              
              _buildDailyMomentum(),
              const SizedBox(height: 16),

              _buildDailyStreak(),
              const SizedBox(height: 32),
              
              _buildQuickStats(),
              const SizedBox(height: 32),
              
              _buildUpcomingDeadlines(),
              const SizedBox(height: 32),
              
              _buildRecentInsights(),
              const SizedBox(height: 160), // Extra padding for bottom nav and FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return Obx(() {
      final now = DateTime.now();
      String greeting = 'Hello';
      if (now.hour < 12) {
        greeting = 'Good Morning';
      } else if (now.hour < 17) {
        greeting = 'Good Afternoon';
      } else {
        greeting = 'Good Evening';
      }

      final authController = Get.find<AuthController>();
      final user = authController.currentUser.value;
      final userName = user?.displayName ?? user?.email?.split('@').first ?? 'Guest';

      const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final dateString = '${days[now.weekday % 7]}, ${now.day} ${months[now.month - 1]} ${now.year}';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting, $userName!',
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            dateString,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
          ),
        ],
      );
    });
  }

  // 2. Daily Momentum Placeholder
  Widget _buildDailyMomentum() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Obx(() {
        final points = controller.todayMomentum.value;
        final target = controller.targetMomentum;
        
        return Column(
          children: [
            const Text(
              'Daily Momentum',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const SizedBox(height: 32),
            
            // 🔥 MASUKKAN REAKTOR DI SINI
            CyberReactor(points: points, target: target),
            
            const SizedBox(height: 32),
            Text(
              '$points / $target Activities Completed',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            if (points >= target) ...[
              const SizedBox(height: 8),
              const Text(
                'Reactor Overload! You are on fire 🔥',
                style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
              )
            ]
          ],
        );
      }),
    );
  }

  // 🔥 UI Daily Streak
  Widget _buildDailyStreak() {
    return Obx(() {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStreakItem('Current Streak', controller.currentStreak.value, Icons.local_fire_department, Colors.orange),
                Container(width: 1, height: 40, color: Colors.white12),
                _buildStreakItem('Best Streak', controller.bestStreak.value, Icons.emoji_events, Colors.amber),
              ],
            ),
            const SizedBox(height: 24),
            _buildStreakIndicators(),
          ],
        ),
      );
    });
  }

  Widget _buildStreakIndicators() {
    final now = DateTime.now();
    final daysList = List.generate(7, (index) {
      return now.subtract(Duration(days: 6 - index));
    });

    final activeDatesSet = controller.activeDatesList.toSet();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: daysList.map((date) {
        final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
        final isActive = activeDatesSet.contains(dateStr);
        final dayName = ['M', 'T', 'W', 'T', 'F', 'S', 'S'][date.weekday - 1];

        return Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isActive ? AppColors.primary : Colors.white24,
                  width: 2,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: isActive
                  ? const Icon(Icons.check, size: 14, color: Colors.black)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              dayName,
              style: TextStyle(
                color: isActive ? AppColors.primary : Colors.white54,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildStreakItem(String title, int days, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: days > 0 ? color : Colors.white24, size: 24),
            const SizedBox(width: 8),
            Text(
              '$days',
              style: TextStyle(
                color: days > 0 ? Colors.white : Colors.white54,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // 3. Quick Stats Widget
  Widget _buildQuickStats() {
    return Obx(() => Row(
      children: [
        Expanded(
          child: _statCard(
            title: 'Active Tasks',
            value: controller.activeTasksCount.value.toString(),
            icon: Icons.check_circle_outline,
            color: Colors.cyan,
            onTap: () => controller.navigateToTab(1), // Index tab Tasks
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            title: 'Logs-Last 30 Days', // Ubah teksnya biar user tau ini data 30 hari
            value: controller.totalLogsCount.value.toString(),
            icon: Icons.history,
            color: Colors.purpleAccent,
            onTap: () => controller.navigateToCompletedLogs(), // Panggil fungsi navigasi khusus
          ),
        ),
      ],
    ));
  }

  Widget _statCard({required String title, required String value, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. Upcoming Deadlines Section
  Widget _buildUpcomingDeadlines() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Upcoming Deadlines', 
          actionText: 'See All', 
          onTap: () => controller.navigateToTab(1) // Lempar ke tab Tasks
        ),
        const SizedBox(height: 16),
        
        Obx(() {
          if (controller.upcomingDeadlines.isEmpty) {
            return _buildEmptyState('No upcoming deadlines in 7 days.', Icons.coffee);
          }
          
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.upcomingDeadlines.length,
            itemBuilder: (context, index) {
              final doc = controller.upcomingDeadlines[index];
              final data = doc.data() as Map<String, dynamic>;
              final title = data['title']?.toString() ?? 'Task';
              final deadline = (data['deadline'] as Timestamp).toDate();
              
              return InkWell(
                onTap: () => _showTaskDetailBottomSheet(data, doc.id),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border(left: BorderSide(color: Colors.orange.withValues(alpha: 0.8), width: 4)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text('Deadline: ${_formatDeadline(deadline)}', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
                          ],
                        ),
                      ),
                      Icon(Icons.circle_outlined, color: Colors.white.withValues(alpha: 0.3)),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  // 5. Recent Insights Section
  Widget _buildRecentInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: '💡 Recent Insights', 
          actionText: 'Go to Reflections', 
          onTap: () => controller.navigateToTab(2), 
        ),
        const SizedBox(height: 16),
        
        Obx(() {
          if (controller.recentInsights.isEmpty) {
            return _buildEmptyState('No insights recorded yet.', Icons.edit_note);
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.recentInsights.length,
            itemBuilder: (context, index) {
              final doc = controller.recentInsights[index];
              final data = doc.data() as Map<String, dynamic>;
              final note = data['note']?.toString() ?? '';
              final title = data['title']?.toString() ?? 'Activity';
              
              return InkWell(
                onTap: () => _showInsightDetailBottomSheet(data, doc.id),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: const Border(left: BorderSide(color: AppColors.primary, width: 4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"$note"',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 8),
                      Text('From: $title', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.2), size: 32),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 14)),
        ],
      ),
    );
  }

  // Update Section Header biar teks "See All" nya bisa di-tap
  Widget _buildSectionHeader({required String title, required String actionText, required VoidCallback onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        InkWell(
          onTap: onTap,
          child: Text(actionText, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  void _showTaskDetailBottomSheet(Map<String, dynamic> data, String docId) {
    // Similar to TaskView bottom sheet
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            Text(data['title']?.toString() ?? 'Task', style: Get.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if ((data['description']?.toString() ?? '').isNotEmpty) ...[
              Text(data['description'].toString(), style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
            ],
            const Divider(color: Colors.white12),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.back();
                      Get.toNamed('/add-entry', arguments: {'isEdit': true, 'docId': docId, 'data': data});
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text('Edit', style: TextStyle(color: Colors.white)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      FirebaseFirestore.instance.collection('entries').doc(docId).delete();
                    },
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text('Delete', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showInsightDetailBottomSheet(Map<String, dynamic> data, String docId) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            Text(data['title']?.toString() ?? 'Activity', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Divider(color: Colors.white12),
            const SizedBox(height: 16),
            Text(data['note']?.toString() ?? '', style: const TextStyle(color: Colors.white, fontSize: 16, fontStyle: FontStyle.italic)),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.back();
                      Get.toNamed('/add-entry', arguments: {'isEdit': true, 'docId': docId, 'data': data});
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text('Edit', style: TextStyle(color: Colors.white)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      FirebaseFirestore.instance.collection('entries').doc(docId).delete();
                    },
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text('Delete', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 🔥 KUSTOM WIDGET: THE CYBER REACTOR
class CyberReactor extends StatefulWidget {
  final int points;
  final int target;

  const CyberReactor({super.key, required this.points, required this.target});

  @override
  State<CyberReactor> createState() => _CyberReactorState();
}

class _CyberReactorState extends State<CyberReactor> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller animasi putaran
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10));
    _updateAnimation();
  }

  @override
  void didUpdateWidget(CyberReactor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    // Logika kecepatan putaran berdasarkan poin
    if (widget.points == 0) {
      _controller.stop();
    } else if (widget.points == 1) {
      _controller.duration = const Duration(seconds: 8); // Putar pelan
      _controller.repeat();
    } else if (widget.points == 2) {
      _controller.duration = const Duration(seconds: 4); // Putar sedang
      _controller.repeat();
    } else {
      _controller.duration = const Duration(seconds: 1); // Putar ngebut (Overload!)
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Kalkulasi intensitas cahaya
    final ratio = (widget.points / widget.target).clamp(0.0, 1.0);
    final isMax = widget.points >= widget.target;

    final glowColor = AppColors.primary.withValues(alpha: 0.2 + (0.4 * ratio));
    final blurRadius = widget.points == 0 ? 0.0 : 15.0 + (15.0 * ratio);

    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Efek Neon Glow (Membesar kalau poin nambah)
        boxShadow: [
          if (widget.points > 0)
            BoxShadow(
              color: glowColor,
              blurRadius: blurRadius,
              spreadRadius: blurRadius / 2,
            )
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Lapis 1: Cincin Putar (Sweep Gradient)
          if (widget.points > 0)
            RotationTransition(
              turns: _controller,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.primary.withValues(alpha: 0.2),
                      AppColors.primary,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            
          // Lapis 2: Penutup Tengah (Biar gradientnya kelihatan kayak cincin border)
          Container(
            width: 125, // Sedikit lebih kecil dari 140
            height: 125,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface, // Warna gelap menyesuaikan background card
            ),
          ),
          
          // Lapis 3: Ikon Inti Reaktor
          TweenAnimationBuilder<double>(
            // Efek deg-degan (Pulse) kalau target tercapai
            tween: Tween<double>(begin: 1.0, end: isMax ? 1.2 : 1.0),
            duration: const Duration(seconds: 1),
            curve: Curves.elasticOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Icon(
                  isMax ? Icons.local_fire_department : Icons.bolt,
                  size: 56,
                  color: widget.points == 0
                      ? Colors.white24
                      : AppColors.primary.withValues(alpha: 0.5 + (0.5 * ratio)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}