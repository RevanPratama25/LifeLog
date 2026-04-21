import 'package:get/get.dart';
import 'package:life_log_frontend/app/modules/auth/bindings/auth_binding.dart';
import 'package:life_log_frontend/app/modules/auth/views/register_view.dart';

//Home
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';

//Add Entry
import '../modules/add_entry/bindings/add_entry_binding.dart';
import '../modules/add_entry/views/add_entry_view.dart';

//Timeline
import '../modules/timeline/bindings/timeline_binding.dart';
import '../modules/timeline/views/timeline_view.dart';

//Auth
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';

//Base
import '../modules/base/bindings/base_binding.dart';
import '../modules/base/views/base_view.dart';

// import '../modules/task/bindings/task_binding.dart';
// import '../modules/task/views/task_view.dart';

// import '../modules/log/bindings/log_binding.dart';
// import '../modules/log/views/log_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  // Halaman pertama yang muncul saat aplikasi dibuka
  static const INITIAL = Routes.BASE;

  static final routes = [
    GetPage(
      name: _Paths.BASE,
      page: () => const BaseView(),
      binding: BaseBinding(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: _Paths.ADD_ENTRY,
      page: () => const AddEntryView(),
      binding: AddEntryBinding(),
    ),

    GetPage(
      name: _Paths.TIMELINE,
      page: () => const TimelineView(),
      binding: TimelineBinding(),
    ),

    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),

    // CONTOH UNTUK MODUL LAINNYA NANTI:
    /*
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.TASK,
      page: () => const TaskView(),
      binding: TaskBinding(),
    ),
    GetPage(
      name: _Paths.LOG,
      page: () => const LogView(),
      binding: LogBinding(),
    ),
    */
  ];
}
