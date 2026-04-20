import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ReflectionsView extends StatelessWidget {
  const ReflectionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights & Reflections'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: Colors.white70)),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips (ALL LOGS, PERSONAL, WORK, etc)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                _buildChip('ALL LOGS', true),
                const SizedBox(width: 12),
                _buildChip('PERSONAL', false),
                const SizedBox(width: 12),
                _buildChip('WORK', false),
              ],
            ),
          ),
          const Expanded(child: Center(child: Text('Category Based Log Lists Will Appear Here'))),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: isActive ? Colors.black : Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}