import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';

class TaskView extends StatelessWidget {
  const TaskView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks List'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.sort_rounded, color: AppColors.primary)),
        ],
      ),
      body: const Center(child: Text('All Tasks Will Appear Here')),
    );
  }
}