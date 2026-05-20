import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/home_controller.dart';



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
              _buildHeader(),
              const SizedBox(height: 32),
              
              _buildDailyMomentum(),
              const SizedBox(height: 16),

              _buildWeeklyStreak(),
              const SizedBox(height: 32),
              
              _buildQuickStats(),
              const SizedBox(height: 32),
              
              _buildUpcomingDeadlines(),
              const SizedBox(height: 32),
              
              _buildRecentInsights(),
              const SizedBox(height: 80), // Extra padding for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  // 1. Personalized Header & Streak
  Widget _buildHeader() {
    // List nama hari dalam Bahasa Inggris sesuai refactoring documentation
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    final now = DateTime.now();
    final dateString = '${days[now.weekday % 7]}, ${now.day} ${months[now.month - 1]} ${now.year}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hello, Revan!', // Nama user
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              dateString, // Tanggal real-time
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
            ),
          ],
        ),
      ],
    );
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

  // 🔥 UI Weekly Streak (LinkedIn Style, tapi Dark/Teal Theme)
  Widget _buildWeeklyStreak() {
    final days = ['Sn', 'Sl', 'Rb', 'Km', 'Jm', 'Sb', 'Mg'];
    final now = DateTime.now();

    return Obx(() {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Streak
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Weekly Consistency',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Icon(Icons.local_fire_department, color: controller.currentStreak.value > 0 ? Colors.orange : Colors.white24, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      '${controller.currentStreak.value} Days',
                      style: TextStyle(
                        color: controller.currentStreak.value > 0 ? Colors.orange : Colors.white54,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Barisan Hari (Circles)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final isCompleted = controller.weekCompletion[index];
                final isToday = (now.weekday - 1) == index;

                return Column(
                  children: [
                    Text(
                      days[index],
                      style: TextStyle(
                        color: isToday ? AppColors.primary : Colors.white54,
                        fontSize: 12,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted 
                            ? AppColors.primary 
                            : AppColors.background, // Warna redup kalau belum
                        border: Border.all(
                          color: isCompleted 
                              ? AppColors.primary 
                              : (isToday ? Colors.white38 : Colors.transparent),
                          width: 1.5,
                        ),
                      ),
                      child: isCompleted
                          ? const Icon(Icons.check, color: AppColors.background, size: 18)
                          : (isToday ? Icon(Icons.circle, color: Colors.white.withValues(alpha: 0.1), size: 12) : null),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      );
    });
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
              
              return Container(
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
              
              return Container(
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