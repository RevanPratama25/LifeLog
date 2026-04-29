import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart'; // Untuk HapticFeedback

class AddEntryController extends GetxController {
  final isTaskMode = true.obs; 
  final isLoading = false.obs; 

  final titleController = TextEditingController();
  final descController = TextEditingController();
  final categoryController = TextEditingController();
  final noteController = TextEditingController(); 

  final deadlineDate = Rx<DateTime?>(null);
                                
  // Inisialisasi Firestore & Auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments['isTask'] != null) {
      isTaskMode.value = Get.arguments['isTask'];
    }
  }

  void toggleMode(bool isTask) {
    isTaskMode.value = isTask;
  }

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: deadlineDate.value ?? DateTime.now(),
      firstDate: DateTime.now(), // Can't pick past dates
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.cyan, // Adjusted to AppColors.primary
              onPrimary: Colors.black,
              surface: Color(0xFF1E1E1E), // AppColors.surface
              onSurface: Colors.white,
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

  // Fungsi simpan ke Cloud Firestore
  Future<void> saveEntry() async {
    final title = titleController.text.trim();
    final desc = descController.text.trim();
    final category = categoryController.text.trim().toUpperCase();
    final note = noteController.text.trim();
    
    if (title.isEmpty) {
      _showErrorSnackbar('Judulnya jangan dikosongin ya!');
      return; 
    }

    if (isTaskMode.value && deadlineDate.value == null) {
      _showErrorSnackbar('Tenggat waktunya (deadline) wajib dipilih!');
      return;
    }

    if (isLoading.value) return; 
    isLoading.value = true;

    try {
      // 1. Ambil UID User yang lagi login
      final String uid = _auth.currentUser!.uid;

      // 2. Siapkan Data (Bentuk Map/JSON)
      Map<String, dynamic> entryData = {
        'title': title,
        'description': desc,
        'category': category.isEmpty ? (isTaskMode.value ? 'TASK' : 'LOG') : category,
        'note': note,
        'isTask': isTaskMode.value,
        'isDone': !isTaskMode.value, // Kalau ini Log manual, otomatis 'isDone: true'
        'createdAt': FieldValue.serverTimestamp(),
      };

      // 3. Tambahan data khusus Task
      if (isTaskMode.value) {
        entryData['deadline'] = Timestamp.fromDate(deadlineDate.value!);
        entryData['isDone'] = false; // Status default task
        entryData['isHighPriority'] = false; // Nanti bisa dibikin switch di UI
      } else {
        // Data khusus Log/Reflection
        entryData['tagType'] = 'MOOD: NEUTRAL'; // Default sementara
        entryData['tagIcon'] = 'person';
      }

      // Tembak ke Firestore (Disimpan di bawah folder UID masing-masing user)
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('entries')
          .add(entryData);

      HapticFeedback.lightImpact();
      

      // Clear controller
      titleController.clear();
      descController.clear();
      categoryController.clear();
      noteController.clear();
      deadlineDate.value = null;

      // Balik ke page sebelumnya
      Get.back(); 

      // Tampilkan snackbar
      Get.snackbar(
        'Success!',
        isTaskMode.value ? 'Task has been saved successfully.' : 'Activity has been logged successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
      
    } catch (e) {
      _showErrorSnackbar('Failed to save data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Oops!',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent.withOpacity(0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  // Logic buat ngecek apakah user udah mulai ngetik sesuatu
  bool get isFormDirty =>
      titleController.text.isNotEmpty ||
      categoryController.text.isNotEmpty ||
      descController.text.isNotEmpty ||
      noteController.text.isNotEmpty ||
      deadlineDate.value != null;

  @override
  void onClose() {
    titleController.dispose();
    descController.dispose();
    categoryController.dispose();
    noteController.dispose();
    super.onClose();
  }
}