import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/firestore_helpers.dart';

class AddEntryController extends GetxController {
  final isTaskMode = true.obs;
  final isLoading = false.obs;

  final isEditMode = false.obs;
  String? editDocId;

  // Stores initial form values to detect unsaved changes

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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();

    // Check if arguments were passed from the previous page
    if (Get.arguments != null) {
      // Check default argument (when creating new entry from Home)
      if (Get.arguments['isTask'] != null) {
        isTaskMode.value = Get.arguments['isTask'];
      }

      // Check for Edit Mode arguments
      if (Get.arguments['isEdit'] == true) {
        isEditMode.value = true;
        editDocId = Get.arguments['docId'];

        // Extract the data to edit
        final data = Get.arguments['data'] as Map<String, dynamic>;

        // Pre-fill text controllers with existing data
        titleController.text = data['title']?.toString() ?? '';
        descController.text = data['description']?.toString() ?? '';
        categoryController.text = data['category']?.toString() ?? '';
        noteController.text = data['note']?.toString() ?? '';
        
        // If completed (isDone: true), open as Log mode.
        // Otherwise, follow the original task/log status.
        isTaskMode.value = data['isDone'] == true
            ? false
            : (data['isTask'] == true);

        if (data['deadline'] != null) {
          deadlineDate.value = (data['deadline'] as Timestamp).toDate();
        }
      }
    }

    // Record initial state after all data is populated
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
              primary: AppColors.primary,
              onPrimary: Colors.black,
              surface: AppColors.surface,
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

  /// Saves or updates the entry in Cloud Firestore.
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
        // Log mode = completed (true), Task mode = active (false)
        'isDone': !isTaskMode.value,
      };

      if (isTaskMode.value) {
        entryData['deadline'] = Timestamp.fromDate(deadlineDate.value!);
      }

      // Branch: Update existing entry vs Create new entry
      if (isEditMode.value && editDocId != null) {
        // Update the existing document
        await userEntriesRef(_firestore, uid)
            .doc(editDocId)
            .update(entryData);
      } else {
        // Create a new document
        entryData['createdAt'] = FieldValue.serverTimestamp();
        await userEntriesRef(_firestore, uid)
            .add(entryData);
      }

      HapticFeedback.lightImpact();

      // Clear form fields
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
        backgroundColor: Colors.green.withValues(alpha: 0.8),
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
      backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  /// Whether the user has made any changes to the form.
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
