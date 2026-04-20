import 'package:get/get.dart';

import '../controllers/add_entry_controller.dart';

class AddEntryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddEntryController>(
      () => AddEntryController(),
    );
  }
}
