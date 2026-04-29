import 'package:get/get.dart';
import 'package:life_log_frontend/app/modules/tasks/controllers/tasks_controller.dart';

class TaskBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TaskController>(
      () => TaskController(),
    );
  }
}
