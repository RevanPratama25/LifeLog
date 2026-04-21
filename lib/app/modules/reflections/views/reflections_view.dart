import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reflections_controller.dart';
import '../../../core/theme/app_colors.dart';

class ReflectionsView extends GetView<ReflectionsController> {
  const ReflectionsView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ReflectionsController());

    return Scaffold(
      appBar: _buildCustomAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          _buildCategoryChips(),
          const SizedBox(height: 16),
          _buildHeader(),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: controller.allLogs.length,
              itemBuilder: (context, index) {
                return _buildReflectionCard(controller.allLogs[index]);
              },
            ),
          ),
          const SizedBox(height: 80), // Hindari tertutup navbar
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
        const CircleAvatar(radius: 14, backgroundImage: NetworkImage('https://i.pravatar.cc/100')), // Dummy avatar kayak di gambar
        const SizedBox(width: 24),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search your reflections...',
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: const Icon(Icons.search, color: Colors.white38),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = ['ALL LOGS', 'PERSONAL', 'WORK'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Obx(() => Row(
            children: categories.map((cat) {
              final isActive = controller.selectedCategory.value == cat;
              return GestureDetector(
                onTap: () => controller.setCategory(cat),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isActive ? AppColors.primary : Colors.white12),
                    boxShadow: isActive ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8)] : [],
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: isActive ? Colors.black : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          )),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Recent Reflections', style: Get.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text('14 ENTRIES', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _buildReflectionCard(dynamic item) {
    // 1. Cast data
    final Map<String, dynamic> log = Map<String, dynamic>.from(item);
    
    // 2. Ekstrak data aman
    final String category = log['category']?.toString() ?? 'LOG';
    final String date = log['date']?.toString() ?? '';
    final String title = log['title']?.toString() ?? 'Tanpa Judul';
    final String content = log['content']?.toString() ?? '';
    final String tagIcon = log['tagIcon']?.toString() ?? '';
    final String tagType = log['tagType']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary, boxShadow: [BoxShadow(color: AppColors.primary, blurRadius: 4)]),
                  ),
                  const SizedBox(width: 8),
                  Text(category, style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                ],
              ),
              Text(date, style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(color: Colors.white70, height: 1.5, fontSize: 14)),
          
          const SizedBox(height: 20),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),
          
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: Icon(
                  tagIcon == 'person' ? Icons.person : 
                  tagIcon == 'energy' ? Icons.bolt : Icons.self_improvement,
                  size: 14, color: AppColors.primary
                ),
              ),
              const SizedBox(width: 8),
              Text(tagType, style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ],
          )
        ],
      ),
    );
  }
}