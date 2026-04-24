import 'package:get/get.dart';

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

//Tasks
import '../modules/tasks/bindings/tasks_binding.dart';
import '../modules/tasks/views/tasks_view.dart';

//Root
import '../modules/root/bindings/root_binding.dart';
import '../modules/root/views/root_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  // Halaman pertama yang muncul saat aplikasi dibuka
  static const INITIAL = Routes.ROOT;

  static final routes = [
    GetPage(
      name: _Paths.ROOT,
      page: () => const RootView(),
      binding: RootBinding(),
      transition: Transition.fadeIn,
    ),

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

    GetPage(
      name: _Paths.TASK,
      page: () => const TaskView(),
      binding: TaskBinding(),
    ),
  ];
}
