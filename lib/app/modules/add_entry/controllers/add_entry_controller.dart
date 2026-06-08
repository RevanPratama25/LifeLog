import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/firestore_helpers.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/constants/alarm_sound_registry.dart';

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
  List<String> _initialReminders = ['at_deadline'];
  bool _initialEnableAlarm = false;
  String _initialAlarmSound = AlarmSoundRegistry.classic;

  final deadlineDate = Rx<DateTime?>(null);
  final selectedReminders = <String>['at_deadline'].obs;
  final enableAlarm = false.obs;
  final alarmSound = AlarmSoundRegistry.classic.obs;

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

        if (data['reminders'] != null) {
          selectedReminders.value = List<String>.from(data['reminders']);
        } else {
          selectedReminders.value = ['at_deadline'];
        }

        enableAlarm.value = data['enableAlarm'] == true;
        
        if (data['alarmSound'] != null) {
          alarmSound.value = data['alarmSound'];
        } else {
          alarmSound.value = AlarmSoundRegistry.classic;
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
    _initialReminders = List<String>.from(selectedReminders);
    _initialEnableAlarm = enableAlarm.value;
    _initialAlarmSound = alarmSound.value;
  }

  void toggleMode(bool isTask) {
    isTaskMode.value = isTask;
  }

  void toggleReminder(String offset) {
    if (selectedReminders.contains(offset)) {
      selectedReminders.remove(offset);
    } else {
      selectedReminders.add(offset);
    }
  }

  Future<void> pickDeadline(BuildContext context) async {
    // 1. Pilih Tanggal Dulu
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: deadlineDate.value ?? DateTime.now(),
      firstDate: DateTime.now(), // Nggak bisa milih tanggal masa lalu
      lastDate: DateTime(DateTime.now().year + 5), // Maksimal 5 tahun ke depan
      builder: (context, child) {
        // Biar pop-up kalendernya ngikutin tema dark/teal lu
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.teal, // Sesuaikan dengan AppColors.primary lu
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E), // AppColors.surface
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    // Kalau user klik 'Cancel' di kalender, batalkan proses
    if (pickedDate == null) return;
    if (!context.mounted) return;

    // 2. Lanjut Pilih Jam
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: deadlineDate.value != null 
          ? TimeOfDay.fromDateTime(deadlineDate.value!) 
          : TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.teal, 
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    // Kalau user klik 'Cancel' di jam, batalkan proses (tanggal nggak jadi disave)
    if (pickedTime == null) return;

    // 3. Gabungkan Tanggal dan Jam jadi satu objek DateTime
    final finalDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    // Update Rx variable lu
    deadlineDate.value = finalDateTime;
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
      final NotificationService notificationService =
          Get.find<NotificationService>();

      Map<String, dynamic> entryData = {
        'title': title,
        'description': desc,
        'category': category.isEmpty
            ? (isTaskMode.value ? 'TASK' : 'LOG')
            : category,
        'note': note,
        'isTask': isTaskMode.value,
        'isDone': !isTaskMode.value, // Kalau Log, otomatis Done
      };

      if (isTaskMode.value) {
        entryData['deadline'] = Timestamp.fromDate(deadlineDate.value!);
        entryData['reminders'] = selectedReminders.toList();
        entryData['enableAlarm'] = enableAlarm.value;
        entryData['alarmSound'] = alarmSound.value;
      }

      String currentDocId;

      // Branch: Update existing entry vs Create new entry
      if (isEditMode.value && editDocId != null) {
        currentDocId = editDocId!;
        // Update data di Firestore
        await userEntriesRef(
          _firestore,
          uid,
        ).doc(currentDocId).update(entryData);

        // Cancel notifikasi lama pakai fungsi baru
        await notificationService.cancelTaskReminders(currentDocId);
      } else {
        // Create data baru
        entryData['createdAt'] = FieldValue.serverTimestamp();
        final docRef = await userEntriesRef(_firestore, uid).add(entryData);
        currentDocId = docRef.id; // Ambil docId yang baru digenerate Firestore
      }

      if (isTaskMode.value && entryData['isDone'] == false && deadlineDate.value != null && selectedReminders.isNotEmpty) {
        await notificationService.scheduleTaskReminders(
          docId: currentDocId,
          title: '⏳ Task Reminder: $title',
          body: 'Hey, just a reminder for your task!',
          deadline: deadlineDate.value!,
          reminders: selectedReminders.toList(),
          enableAlarm: enableAlarm.value,
          alarmSound: alarmSound.value,
        );
      }
      HapticFeedback.lightImpact();

      // Clear form fields
      titleController.clear();
      descController.clear();
      categoryController.clear();
      noteController.clear();
      deadlineDate.value = null;
      selectedReminders.value = ['at_deadline'];
      enableAlarm.value = false;
      alarmSound.value = AlarmSoundRegistry.classic;

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
        deadlineDate.value != _initialDeadline ||
        !_listEquals(selectedReminders, _initialReminders) ||
        enableAlarm.value != _initialEnableAlarm ||
        alarmSound.value != _initialAlarmSound;
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
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
