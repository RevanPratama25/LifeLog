import 'package:get/get.dart';
import '../controllers/reflections_controller.dart';

class ReflectionsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReflectionController>(() => ReflectionController());
  }
}
