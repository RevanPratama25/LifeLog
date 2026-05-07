import 'package:get/get.dart';
import '../controllers/tasks_controller.dart';

class TaskBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TaskController>(
      () => TaskController(),
    );
  }
}
