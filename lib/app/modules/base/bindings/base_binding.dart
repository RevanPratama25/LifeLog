import 'package:get/get.dart';
import '../controllers/base_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../timeline/controllers/timeline_controller.dart';

class BaseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BaseController>(() => BaseController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<TimelineController>(() => TimelineController());
    // Get.lazyPut<TaskController>(() => TaskController());
    // Get.lazyPut<LogController>(() => LogController());
  }
}