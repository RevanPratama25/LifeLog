import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/add_entry_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/alarm_sound_registry.dart';
import '../../../core/widgets/custom_text_field.dart';

class AddEntryView extends GetView<AddEntryController> {
  const AddEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // Check for unsaved changes before exiting
        if (controller.hasUnsavedChanges) {
          final confirm = await Get.dialog<bool>(
            AlertDialog(
              title: const Text('Hold On!'),
              content: const Text(
                  'You have unsaved changes. Are you sure you want to exit?'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Get.back(result: true),
                  child: const Text('Exit'),
                ),
              ],
            ),
          );
          // If user confirmed exit, proceed with navigation
          if (confirm == true) {
            Get.back();
          }
        } else {
          // No unsaved changes — navigate back immediately
          Get.back();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Obx(
            () => Text(
              controller.isEditMode.value
                  ? 'Edit Data'
                  : (controller.isTaskMode.value
                        ? 'Add Plan'
                        : 'Record Activity'),
              style: Get.textTheme.titleLarge,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeToggle(),
              const SizedBox(height: 32),
              CustomTextField(
                label: 'Title',
                controller: controller.titleController,
                hint: 'E.g. Learn GetX',
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Category',
                controller: controller.categoryController,
                hint: 'E.g. Study, Hobby...',
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Description',
                controller: controller.descController,
                hint: 'Optional details...',
                maxLines: 3,
              ),

              const SizedBox(height: 20),
              // Dynamic form section based on selected mode
              Obx(
                () => controller.isTaskMode.value
                    ? _buildTaskExtras(context)
                    : _buildLogExtras(),
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: Obx(
                  () => ElevatedButton(
                    // Disable button while loading
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.saveEntry(),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            controller.isEditMode.value ? 'Update' : 'Save',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Toggle button: Task vs Log mode
  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => controller.toggleMode(true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: controller.isTaskMode.value
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: controller.isTaskMode.value
                          ? AppColors.primary
                          : Colors.transparent,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Task',
                      style: TextStyle(
                        color: controller.isTaskMode.value
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.toggleMode(false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: !controller.isTaskMode.value
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: !controller.isTaskMode.value
                          ? AppColors.primary
                          : Colors.transparent,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Log',
                      style: TextStyle(
                        color: !controller.isTaskMode.value
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

 // Extra fields for Task mode (deadline date picker)
  Widget _buildTaskExtras(BuildContext context) { // 🔥 Tambahkan parameter context di sini
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deadline',
          style: Get.textTheme.labelLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        // 🔥 Obx dipindah ke luar InkWell biar lebih stabil nangkep UI update
        Obx(() => InkWell(
          // 🔥 PERBAIKAN UTAMA: Tambahkan (context) agar fungsi tereksekusi
          onTap: () => controller.pickDeadline(context), 
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                // Biar ada efek visual kalau udah diisi vs belum diisi
                color: controller.deadlineDate.value == null 
                    ? Colors.transparent 
                    : AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  controller.deadlineDate.value == null
                      ? 'Deadline Time'
                      : DateFormat('dd MMMM yyyy, HH:mm')
                          .format(controller.deadlineDate.value!),
                  style: TextStyle(
                    color: controller.deadlineDate.value == null
                        ? AppColors.textSecondary
                        : Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        )),
        const SizedBox(height: 24),
        Text(
          'Reminders',
          style: Get.textTheme.labelLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final options = {
            'at_deadline': 'At deadline',
            '30_min': '30 mins before',
            '1_hour': '1 hour before',
            '3_hours': '3 hours before',
            '5_hours': '5 hours before',
            '12_hours': '12 hours before',
            '1_day': '1 day before',
            '3_days': '3 days before',
            '7_days': '7 days before',
          };
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.entries.map((entry) {
              final isSelected = controller.selectedReminders.contains(entry.key);
              return FilterChip(
                label: Text(entry.value),
                selected: isSelected,
                onSelected: (_) => controller.toggleReminder(entry.key),
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : Colors.white70,
                ),
              );
            }).toList(),
          );
        }),
        const SizedBox(height: 24),
        Obx(() => SwitchListTile(
          title: const Text('Enable Alarm'),
          subtitle: const Text('Play a loud alarm sound when the reminder triggers'),
          value: controller.enableAlarm.value,
          onChanged: (val) => controller.enableAlarm.value = val,
          activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
          activeThumbColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
        )),
        Obx(() {
          if (!controller.enableAlarm.value) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Alarm Sound',
                style: Get.textTheme.labelLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              ...AlarmSoundRegistry.availableSounds.map((sound) {
                // ignore: deprecated_member_use
                return RadioListTile<String>(
                  title: Text(AlarmSoundRegistry.getDisplayName(sound), style: const TextStyle(color: Colors.white)),
                  value: sound,
                  // ignore: deprecated_member_use
                  groupValue: controller.alarmSound.value,
                  // ignore: deprecated_member_use
                  onChanged: (val) {
                    if (val != null) controller.alarmSound.value = val;
                  },
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                );
              }),
            ],
          );
        }),
      ],
    );
  }
  // Extra fields for Log mode (notes/insight)
  Widget _buildLogExtras() {
    return CustomTextField(
      label: 'Notes / Insight (Optional)',
      controller: controller.noteController,
      hint: 'What did you learn from this activity?',
      maxLines: 4,
      icon: Icons.lightbulb_outline,
    );
  }
}
