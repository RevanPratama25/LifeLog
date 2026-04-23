import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddEntryController extends GetxController {
  final isTaskMode = true.obs; 
  final isLoading = false.obs; 

  final titleController = TextEditingController();
  final descController = TextEditingController();
  final categoryController = TextEditingController();
  final noteController = TextEditingController(); 

  final deadlineDate = Rx<DateTime?>(null);

  // 🔥 Inisialisasi Firestore & Auth
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

  void pickDate() async {
    DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00B4D8),
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E),
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
        'createdAt': FieldValue.serverTimestamp(), // Waktu asli server Firebase
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

      // 4. Tembak ke Firestore (Disimpan di bawah folder UID masing-masing user)
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('entries')
          .add(entryData);

      Get.snackbar(
        'Mantap!',
        isTaskMode.value ? 'Rencana berhasil disimpan.' : 'Aktivitas berhasil dicatat.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      
      Get.back(); // Kembali ke Dashboard/Previous Page
      
    } catch (e) {
      _showErrorSnackbar('Gagal menyimpan data: $e');
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

  @override
  void onClose() {
    titleController.dispose();
    descController.dispose();
    categoryController.dispose();
    noteController.dispose();
    super.onClose();
  }
}