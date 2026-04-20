import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddEntryController extends GetxController {
  // Toggle: true = Task (Rencana), false = Log (Aktivitas Spontan)
  final isTaskMode = true.obs; 
  final isLoading = false.obs;  

  // Form Controllers
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final categoryController = TextEditingController();
  final noteController = TextEditingController(); // Khusus Log

  // Khusus Task (Deadline)
  final deadlineDate = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    // Cek apakah ada argumen yang dikirim
    if (Get.arguments != null && Get.arguments['isTask'] != null) {
      isTaskMode.value = Get.arguments['isTask'];
    }
  }

  void toggleMode(bool isTask) {
    isTaskMode.value = isTask;
  }

  // Fungsi pura-pura buat UI Skeleton dulu
  void pickDate() async {
    DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          // Biar kalendernya ngikutin tema Dark Mode lu
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00B4D8), // AppColors.primary
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E), // AppColors.surface
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      deadlineDate.value = picked;
    }
  }

  Future<void> saveEntry() async {
    // 1. Logic Validation & Trimming
    final title = titleController.text.trim();
    
    if (title.isEmpty) {
      _showErrorSnackbar('You forgot the title buddy!');
      return; // Berhenti di sini, gak lanjut simpan
    }

    if (isTaskMode.value && deadlineDate.value == null) {
      _showErrorSnackbar('You need to fill the deadline buddy!');
      return;
    }

    // 2. Logic Loading State (Mencegah double tap)
    if (isLoading.value) return; 
    isLoading.value = true;

    try {
      // ⏳ Simulasi delay network/Firebase selama 2 detik
      await Future.delayed(const Duration(seconds: 2));

      // Nanti kode insert ke Firebase taruh di sini
      // title, categoryController.text.trim(), dst...

      Get.snackbar(
        'Mantap!',
        isTaskMode.value ? 'Task saved successfully.' : 'Log saved successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      
      Get.back(); // Kembali ke Home setelah sukses
      
    } catch (e) {
      _showErrorSnackbar('Failed to save data: $e');
    } finally {
      // Pastikan loading dimatikan apapun yang terjadi (sukses/gagal)
      isLoading.value = false;
    }
  }

  // Helper fungsi biar kode bersih
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Oops!',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  void onClose() {
    titleController.dispose();
    descController.dispose();
    categoryController.dispose();
    noteController.dispose();
    super.onClose();
  }
}