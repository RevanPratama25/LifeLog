import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Jangan lupa package ini buat format tanggal
import '../controllers/add_entry_controller.dart';
import '../../../core/theme/app_colors.dart';

class AddEntryView extends GetView<AddEntryController> {
  const AddEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, //Kita matikan fungsi pop otomatis
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // Kalau udah pop, jangan lakukan apa-apa

        // Cek apakah form ada isinya
        if (controller.isFormDirty) {
          // Tampilkan dialog konfirmasi
          _showExitConfirmation();
        } else {
          // Kalau kosong, langsung balik
          Get.back();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Obx(
            () => Text(
              controller.isTaskMode.value
                  ? 'Tambah Rencana'
                  : 'Catat Aktivitas',
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
              _buildInput(
                label: 'Title',
                controller: controller.titleController,
                hint: 'Contoh: Learn GetX',
              ),
              const SizedBox(height: 20),
              _buildInput(
                label: 'Category',
                controller: controller.categoryController,
                hint: 'Contoh: Study, Hobby...',
              ),
              const SizedBox(height: 20),
              _buildInput(
                label: 'Description',
                controller: controller.descController,
                hint: 'Optional details...',
                maxLines: 3,
              ),

              const SizedBox(height: 20),
              // Form dinamis berubah tergantung mode yang dipilih
              Obx(
                () => controller.isTaskMode.value
                    ? _buildTaskExtras()
                    : _buildLogExtras(),
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: Obx(
                  () => ElevatedButton(
                    // ... style sama kayak sebelumnya ...
                    // Matikan fungsi klik kalau lagi loading
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
                        : const Text(
                            'Save',
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

  // 1. Toggle Button Plan vs Action
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
                        ? AppColors.primary.withOpacity(0.2)
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
                        ? AppColors.primary.withOpacity(0.2)
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

  // 2. Extra Field buat Task (Deadline Date Picker)
  Widget _buildTaskExtras() {
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
        InkWell(
          onTap: controller.pickDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.transparent),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Obx(
                  () => Text(
                    controller.deadlineDate.value == null
                        ? 'Pilih Tanggal'
                        : DateFormat(
                            'dd MMMM yyyy',
                          ).format(controller.deadlineDate.value!),
                    style: TextStyle(
                      color: controller.deadlineDate.value == null
                          ? AppColors.textSecondary
                          : Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 3. Extra Field buat Log (Notes/Insight)
  Widget _buildLogExtras() {
    return _buildInput(
      label: 'Catatan / Insight (Opsional)',
      controller: controller.noteController,
      hint: 'Apa pembelajaran dari aktivitas ini?',
      maxLines: 4,
      icon: Icons.lightbulb_outline,
    );
  }

  

  // Helper untuk Input Text Field biar seragam
  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Get.textTheme.labelLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF555555)),
            prefixIcon: icon != null
                ? Icon(icon, color: AppColors.primary)
                : null,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ), // Efek glow pas diklik
            ),
          ),
        ),
      ],
    );
  }

  // Exit Confirmation Dialog
  void _showExitConfirmation() {
    Get.defaultDialog(
      title: 'Are you sure?',
      middleText: 'The data you have typed will be lost. Are you sure you want to quit?',
      backgroundColor: AppColors.surface,
      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      middleTextStyle: const TextStyle(color: Colors.white70),
      contentPadding: const EdgeInsets.all(20),
      
      // Tombol Batal Keluar
      textCancel: 'Keep Typing',
      cancelTextColor: AppColors.primary,
      
      // Tombol Ya, Keluar
      textConfirm: 'Yes, Quit',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        Get.back(); // Tutup dialog
        Get.back(); // Balik ke halaman sebelumnya (Dashboard)
      },
    );
  }
}
