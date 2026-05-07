import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart'; // Untuk HapticFeedback

class AddEntryController extends GetxController {
  final isTaskMode = true.obs;
  final isLoading = false.obs;

  final isEditMode = false.obs;
  String? editDocId;

  final titleController = TextEditingController();
  final descController = TextEditingController();
  final categoryController = TextEditingController();
  final noteController = TextEditingController();

  String _initialTitle = '';
  String _initialDesc = '';
  String _initialCategory = '';
  String _initialNote = '';
  bool _initialIsTaskMode = true;
  DateTime? _initialDeadline;

  final deadlineDate = Rx<DateTime?>(null);

  // Inisialisasi Firestore & Auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();

    // Cek apakah ada data yang dilempar dari halaman sebelumnya
    if (Get.arguments != null) {
      // Cek argumen default (pas mau bikin baru dari Home)
      if (Get.arguments['isTask'] != null) {
        isTaskMode.value = Get.arguments['isTask'];
      }

      // 🔥 Cek argumen Edit Mode
      if (Get.arguments['isEdit'] == true) {
        isEditMode.value = true;
        editDocId = Get.arguments['docId'];

        // Ekstrak data yang mau diedit
        final data = Get.arguments['data'] as Map<String, dynamic>;

        // Isi otomatis TextController dengan data lama
        titleController.text = data['title']?.toString() ?? '';
        descController.text = data['description']?.toString() ?? '';
        categoryController.text = data['category']?.toString() ?? '';
        noteController.text = data['note']?.toString() ?? '';
        
        // If the data is completed (isDone: true), force it open as Log (false).
        // If not completed yet, follow the original status.
        isTaskMode.value = data['isDone'] == true
            ? false
            : (data['isTask'] == true);

        if (data['deadline'] != null) {
          deadlineDate.value = (data['deadline'] as Timestamp).toDate();
        }
      }
    }

    // 🔥 PINDAH KE SINI: REKAM KONDISI AWAL SETELAH SEMUA DATA DIISI
    _initialTitle = titleController.text;
    _initialDesc = descController.text;
    _initialCategory = categoryController.text;
    _initialNote = noteController.text;
    _initialIsTaskMode = isTaskMode.value;
    _initialDeadline = deadlineDate.value;
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
      _showErrorSnackbar('Title cannot be empty!');
      return;
    }

    if (isTaskMode.value && deadlineDate.value == null) {
      _showErrorSnackbar('Deadline must be chosen!');
      return;
    }

    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final String uid = _auth.currentUser!.uid;

      Map<String, dynamic> entryData = {
        'title': title,
        'description': desc,
        'category': category.isEmpty
            ? (isTaskMode.value ? 'TASK' : 'LOG')
            : category,
        'note': note,
        'isTask': isTaskMode.value,
        // Jangan timpa createdAt dan isDone kalau lagi ngedit

        // Kalo toggle-nya diubah jadi Log, otomatis jadi selesai (true).
        // Kalo toggle-nya dibalikin jadi Task, otomatis jadi aktif lagi (false).
        'isDone': !isTaskMode.value,
      };

      if (isTaskMode.value) {
        entryData['deadline'] = Timestamp.fromDate(deadlineDate.value!);
      }

      // 🔥 LOGIC BERCABANG: Update vs Create
      if (isEditMode.value && editDocId != null) {
        // Update data yang udah ada
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('entries')
            .doc(editDocId)
            .update(entryData);
      } else {
        // Create data baru (logic yang lama)
        entryData['createdAt'] = FieldValue.serverTimestamp();
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('entries')
            .add(entryData);
      }

      HapticFeedback.lightImpact();

      // Bersihin form
      titleController.clear();
      descController.clear();
      categoryController.clear();
      noteController.clear();
      deadlineDate.value = null;

      Get.back();

      Get.snackbar(
        'Ok!',
        isEditMode.value
            ? 'Edited Successfully.'
            : (isTaskMode.value
                  ? 'Task Saved Successfully.'
                  : 'Log Saved Successfully.'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
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
  bool get hasUnsavedChanges {
    return titleController.text != _initialTitle ||
           descController.text != _initialDesc ||
           categoryController.text != _initialCategory ||
           noteController.text != _initialNote ||
           isTaskMode.value != _initialIsTaskMode ||
           deadlineDate.value != _initialDeadline;
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
